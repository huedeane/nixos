{
  description = "My NixOS config";
  
  inputs = {
    # NixOS Rolling Release
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
   
    # Configuration Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hyprland
    hyprland.url = "github:hyprwm/Hyprland";
    
    # Hyprland Plugin: Workspaces Enhancement
    split-monitor-workspaces = {
      url = "github:zjeffer/split-monitor-workspaces";
      inputs.hyprland.follows = "hyprland";
    };
  };

  outputs = { 
    self,
    nixpkgs, 
    home-manager,
    hyprland,
    split-monitor-workspaces,
    ... 
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    configDir = self.outPath;
    configHomeDir = "${self.outPath}/home/configuration";
  in {
    nixosConfigurations = {
      laptop = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/laptop/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
              users.huedeane = import ./home/profiles/main.nix;
              extraSpecialArgs = {
                inherit inputs configDir configHomeDir;
                hostname = "laptop";
                username = "huedeane";
              };
            };
          }
        ];
      };
    };
  };
}
