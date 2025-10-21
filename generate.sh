#!/usr/bin/env bash
# Generate static system directories for nix-systems
# Run this script when adding new systems or updating the structure

set -euo pipefail

# Base systems (sorted alphabetically)
SYSTEMS=(
  "aarch64-darwin"
  "aarch64-linux"
  "x86_64-linux"
)

create_system_dir() {
  local dir_name=$1
  shift
  local systems=("$@")

  echo "  Creating ${dir_name}/"
  mkdir -p "${dir_name}"

  # Create flake.nix
  cat > "${dir_name}/flake.nix" << 'EOF'
{ outputs = _: { }; }
EOF

  # Create default.nix with list of systems
  {
    echo -n "[ "
    for i in "${!systems[@]}"; do
      if [ $i -gt 0 ]; then
        echo -n " "
      fi
      echo -n "\"${systems[$i]}\""
    done
    echo " ]"
  } > "${dir_name}/default.nix"
}

echo "Generating system directories..."

# Generate single-system directories
for sys in "${SYSTEMS[@]}"; do
  create_system_dir "${sys}" "${sys}"
done

# Generate 2-system combinations (sorted)
create_system_dir "aarch64-darwin,aarch64-linux" "aarch64-darwin" "aarch64-linux"
create_system_dir "aarch64-darwin,x86_64-linux" "aarch64-darwin" "x86_64-linux"
create_system_dir "aarch64-linux,x86_64-linux" "aarch64-linux" "x86_64-linux"

# Generate 3-system combination (all systems)
create_system_dir "aarch64-darwin,aarch64-linux,x86_64-linux" "aarch64-darwin" "aarch64-linux" "x86_64-linux"

total_dirs=$((${#SYSTEMS[@]} + 3 + 1))  # singles + pairs + triple
echo "Done! Generated ${total_dirs} system directories."
