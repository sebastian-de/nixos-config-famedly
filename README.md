# nixos-config-famedly

Nix configuration including settings for

- [Home Manager](https://github.com/nix-community/home-manager)
- [plasma-manager](https://github.com/nix-community/plasma-manager)
- [nixvim](https://github.com/nix-community/nixvim)

Includes the [Famedly NixOS flake](https://github.com/famedly/famedly-nixos).

Matrix room: [#nix:famedly.de](https://matrix.to/#/#nix:famedly.de)

## Building a VM

On NixOS:
```sh
nixos-rebuild build-vm --flake .
```

On Non-NixOS:
```sh
nix build -L .#nixosConfigurations.burrito.config.system.build.vm
```

The VM can than be run from `./result/bin/run-nixos-vm`

## Generate Plasma config

`plasma-manager` offers a utility called `rc2nix` to generate a Nix configuration from a live system.

```sh
nix run github:nix-community/plasma-manager > rc2nix-generated.nix
```

## System rebuild

```sh
nixos-rebuild switch --sudo --flake .
```
