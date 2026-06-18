{
  description = "NixOS configuration for Famedly work laptop";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-26.05";
    famedly-nixos.url = "git+ssh://git@github.com/famedly/famedly-nixos";
    home-manager = {
      url = "github:nix-community/home-manager?ref=release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nixvim = {
      url = "github:nix-community/nixvim/nixos-26.05";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database.url = "github:nix-community/nix-index-database";
  };

  outputs =
    {
      nixpkgs,
      famedly-nixos,
      home-manager,
      plasma-manager,
      nixvim,
      nix-index-database,
      ...
    }@inputs:
    {
      nixosConfigurations.burrito = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.overwriteBackup = true;
            home-manager.sharedModules = [
              plasma-manager.homeModules.plasma-manager
              nixvim.homeModules.nixvim
              nix-index-database.homeModules.default
            ];
            home-manager.users.sepp = import ./home-manager/home.nix;
          }
        ];
        specialArgs.flake-inputs = inputs;
      };
    };
}
