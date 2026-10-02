#!/usr/bin/env bash
# Rebuild the NixOS configuration from this repo without flakes or channels.
# Usage: ./rebuild.sh [switch|boot|test|dry-build|build-vm|...] [extra nixos-rebuild args]
# Defaults to `switch`.
set -euo pipefail
cd "$(dirname "$0")"

cmd=${1:-switch}
if [ $# -gt 0 ]; then shift; fi

nixpkgs_pin=$(nix eval --raw -f npins/default.nix nixpkgs.outPath)
nix_path="nixpkgs=${nixpkgs_pin}:nixos-config=${PWD}/configuration.nix"

NIX_PATH="${nix_path}" nixos-rebuild "$cmd" --sudo --diff "$@"
