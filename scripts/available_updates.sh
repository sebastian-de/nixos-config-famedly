#!/usr/bin/env bash

set -o pipefail

if [[ $# -eq 0 ]]; then
  pkgs=(
    linuxKernel.kernels.linux_latest
    systemd
    kdePackages.plasma-workspace
    kdePackages.kate
    element-desktop
    firefox
    thunderbird
    vscode
  )
else
  pkgs=("$@")
fi

for p in "${pkgs[@]}"; do
  current=$(nix eval --raw nixpkgs#$p.version 2>/dev/null) || current="<eval failed>"
  pinned=$(nix eval --raw --inputs-from . nixpkgs#$p.version 2>/dev/null) || pinned="<eval failed>"
  if [ "$current" != "$pinned" ]; then
    printf '\033[32m%s\033[0m: %s -> %s\n' "$p" "$current" "$pinned"
  else
    echo "$p: $current"
  fi
done
