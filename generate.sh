#!/usr/bin/env bash
# Generate static system directories for nix-systems
# Run this script when adding new systems or updating the structure

set -euo pipefail

SYSTEMS=(
  "x86_64-linux"
  "aarch64-linux"
  "aarch64-darwin"
)

echo "Generating system directories..."

for sys in "${SYSTEMS[@]}"; do
  echo "  Creating ${sys}/"
  mkdir -p "${sys}"

  # Create flake.nix
  cat > "${sys}/flake.nix" << 'EOF'
{ outputs = _: { }; }
EOF

  # Create default.nix
  echo "[ \"${sys}\" ]" > "${sys}/default.nix"
done

echo "Done! Generated ${#SYSTEMS[@]} system directories."
