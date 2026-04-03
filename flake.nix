{
  description = "My NixOS config";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager }: {
    nixosConfigurations = {
      desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/main/configuration.nix
          home-manager.nixosModules.homeManager
          {
            home-manager.users.huedeane = import ./home/home.nix
          }
        ];
      };
    };
  };
}
