# nixos-config-famedly

Nix configuration including settings for

- [Home Manager](https://github.com/nix-community/home-manager)
- [plasma-manager](https://github.com/nix-community/plasma-manager)
- [nixvim](https://github.com/nix-community/nixvim)


This is a plain (non-flake) configuration. All external dependencies (nixpkgs, home-manager, plasma-manager, nixvim, nix-index-database) are pinned with [npins](https://github.com/andir/npins) in `npins/sources.json`. The build entry point is `system.nix`, which imports the pinned nixpkgs and loads `configuration.nix`. The system `<nixpkgs>` and flake registry are pinned to the same source via `nixpkgs.flake.source`. Based on [this blog](https://jade.fyi/blog/pinning-nixos-with-npins/).

## System rebuild

Run from this repo's root. `--file .` loads the `system.nix` entry point (pinned nixpkgs + `configuration.nix`):

```sh
nixos-rebuild switch --sudo --diff --file .
```

## Validate config

```sh
nixos-rebuild dry-build --file .
```

## Building a VM

On NixOS:
```sh
nixos-rebuild build-vm --file .
```

On Non-NixOS:

```sh
nix-build ./system.nix -A vm
```

The VM can than be run from `./result/bin/run-nixos-vm`

## Generate Plasma config

`plasma-manager` offers a utility called `rc2nix` to generate a Nix configuration from a live system.

```sh
nix run github:nix-community/plasma-manager > rc2nix-generated.nix
```

## Update dependencies

```sh
npins update
```

Then rebuild as above. To update a single pin: `npins update nixpkgs`.

## Switching the nixpkgs branch

```sh
npins add github NixOS nixpkgs --branch nixos-unstable
```

home-manager and nixvim are coupled to the nixpkgs release and must be repointed to match, otherwise expect evaluation errors:

```sh
npins add github nix-community home-manager --branch master  # release-26.05 pairs with nixos-26.05
npins add github nix-community nixvim --branch main          # nixos-26.05 branch pairs with nixos-26.05
```

plasma-manager (`trunk`) and nix-index-database (`main`) are release-independent and stay as they are.

Then verify and activate:

```sh
nixos-rebuild dry-build --file .
nixos-rebuild switch --sudo --diff --file .
```
