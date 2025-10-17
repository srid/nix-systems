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

          createSystemDir = sys: ''
            mkdir -p $out/${sys}
            cat > $out/${sys}/flake.nix << 'EOF'
            { outputs = _: { }; }
            EOF
            echo '[ "${sys}" ]' > $out/${sys}/default.nix
          '';

          checkSystemDir = sys: ''
            test -d $built/${sys} || (echo "Missing ${sys} directory" && exit 1)
            test -f $built/${sys}/default.nix || (echo "Missing ${sys}/default.nix" && exit 1)
            test -f $built/${sys}/flake.nix || (echo "Missing ${sys}/flake.nix" && exit 1)
            grep -q '"${sys}"' $built/${sys}/default.nix || (echo "Incorrect ${sys}/default.nix content" && exit 1)
          '';
        in
        {
          packages.default = pkgs.runCommand "nix-systems" { } ''
            mkdir -p $out
            ${lib.concatMapStringsSep "\n" createSystemDir supportedSystems}
          '';

          checks.systems-structure = pkgs.runCommand "check-systems-structure" { } ''
            built=${self'.packages.default}
            ${lib.concatMapStringsSep "\n" checkSystemDir supportedSystems}
            echo "All checks passed!" > $out
          '';
        };
    };
}
