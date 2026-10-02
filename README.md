# nixos-config-famedly

Nix configuration including settings for

- [Home Manager](https://github.com/nix-community/home-manager)
- [plasma-manager](https://github.com/nix-community/plasma-manager)
- [nixvim](https://github.com/nix-community/nixvim)


This is a plain (non-flake) configuration. All external dependencies (nixpkgs, home-manager, plasma-manager, nixvim, nix-index-database) are pinned with [npins](https://github.com/andir/npins) in `npins/sources.json` and imported via `import ./npins` in `configuration.nix`. Channels are not used; the system `<nixpkgs>` and flake registry are pinned to the same source via `nixpkgs.flake.source`. Based on [this blog](https://jade.fyi/blog/pinning-nixos-with-npins/).

## System rebuild

The wrapper script constructs `NIX_PATH` (pinned nixpkgs + this repo's `configuration.nix`) at invocation time:

```sh
./rebuild.sh
```

Without arguments this runs `nixos-rebuild switch --sudo`.

## Validate config

```sh
./rebuild.sh dry-build
```

## Building a VM

On NixOS:
```sh
./rebuild.sh build-vm
```

On Non-NixOS:
```sh
nix-build '<nixpkgs/nixos>' -A vm -I nixpkgs=$(nix eval --raw -f ./npins nixpkgs) -I nixos-config=$PWD/configuration.nix
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
./rebuild.sh dry-build
./rebuild.sh
```
