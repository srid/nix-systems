{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];

      perSystem = { config, self', inputs', pkgs, lib, system, ... }:
        let
          supportedSystems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];

          # Generate directory name from list of systems
          systemDirName = systems: lib.concatStringsSep "," (lib.sort (a: b: a < b) systems);

          # Generate default.nix content from list of systems
          systemListContent = systems:
            let sorted = lib.sort (a: b: a < b) systems;
            in "[ " + (lib.concatMapStringsSep " " (s: ''"${s}"'') sorted) + " ]";

          createSystemDir = sys: ''
            mkdir -p $out/${sys}
            cat > $out/${sys}/flake.nix << 'EOF'
            { outputs = _: { }; }
            EOF
            echo '[ "${sys}" ]' > $out/${sys}/default.nix
          '';

          # Create a combined system directory
          createCombinedSystemDir = systems:
            let
              dirName = systemDirName systems;
              content = systemListContent systems;
            in
            ''
              mkdir -p $out/${dirName}
              cat > $out/${dirName}/flake.nix << 'EOF'
              { outputs = _: { }; }
              EOF
              echo '${content}' > $out/${dirName}/default.nix
            '';

          checkSystemDir = sys: ''
            test -d $built/${sys} || (echo "Missing ${sys} directory" && exit 1)
            test -f $built/${sys}/default.nix || (echo "Missing ${sys}/default.nix" && exit 1)
            test -f $built/${sys}/flake.nix || (echo "Missing ${sys}/flake.nix" && exit 1)
            grep -q '"${sys}"' $built/${sys}/default.nix || (echo "Incorrect ${sys}/default.nix content" && exit 1)
          '';

          checkCombinedSystemDir = systems:
            let
              dirName = systemDirName systems;
            in
            ''
              test -d $built/${dirName} || (echo "Missing ${dirName} directory" && exit 1)
              test -f $built/${dirName}/default.nix || (echo "Missing ${dirName}/default.nix" && exit 1)
              test -f $built/${dirName}/flake.nix || (echo "Missing ${dirName}/flake.nix" && exit 1)
              ${lib.concatMapStringsSep "\n" (s: ''grep -q '"${s}"' $built/${dirName}/default.nix || (echo "Missing ${s} in ${dirName}/default.nix" && exit 1)'') systems}
            '';
        in
        {
          packages.default = pkgs.runCommand "nix-systems" { } ''
            mkdir -p $out
            ${lib.concatMapStringsSep "\n" createSystemDir supportedSystems}
            ${createCombinedSystemDir [ "x86_64-linux" "aarch64-darwin" ]}
          '';

          checks.systems-structure = pkgs.runCommand "check-systems-structure" { } ''
            built=${self'.packages.default}
            ${lib.concatMapStringsSep "\n" checkSystemDir supportedSystems}
            ${checkCombinedSystemDir [ "x86_64-linux" "aarch64-darwin" ]}
            echo "All checks passed!" > $out
          '';
        };
    };
}
