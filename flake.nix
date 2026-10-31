{
  description = "NixOS configuration for Famedly work laptop";

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-26.05/nixexprs.tar.xz";
    famedly-nixos.url = "github:famedly/famedly-nixos";
    home-manager = {
      url = "github:nix-community/home-manager?ref=release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    unstable.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";
  };

  outputs =
    {
      nixpkgs,
      famedly-nixos,
      home-manager,
      plasma-manager,
      nix-index-database,
      unstable,
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
              nix-index-database.homeModules.default
            ];
            home-manager.extraSpecialArgs.flake-inputs = inputs;
            home-manager.users.sepp = import ./home-manager/home.nix;
          }
        ];
        specialArgs.flake-inputs = inputs;
      };
    };
}
