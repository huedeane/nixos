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

    # Encryption
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # User Interface
    ags = {
      url = "github:aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Neovim
    nixCats = {
      url = "github:BirdeeHub/nixCats-nvim";
    };

    # WSL
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      sops-nix,
      nixCats,
      nixos-wsl,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      configDir = self.outPath;
      configHomeDir = "${self.outPath}/home/configuration";
      editMode = builtins.getEnv "EDIT_MODE" == "1";

      sharedArgs = {
        inherit
          inputs
          configDir
          configHomeDir
          editMode
          ;
      };

      mkSystem =
        {
          hostname,
          username,
          hostModule,
          homeProfile,
          extraSystemModules ? [ ],
          extraHomeModules ? [ ],
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit sharedArgs;
            inherit hostname username;
          };
          modules = [
            hostModule
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "backup";
                overwriteBackup = true;
                sharedModules = extraHomeModules;
                users.${username} = homeProfile;
                extraSpecialArgs = {
                  inherit sharedArgs;
                  inherit hostname username;
                };
              };
            }
          ]
          ++ extraSystemModules;
        };
    in
    {
      homeModules = {
        godot = ./derivations/godot/godot.nix;
      };

      nixosConfigurations = {
        laptop = mkSystem {
          hostname = "laptop";
          username = "huedeane";
          hostModule = ./hosts/profiles/laptop/configuration.nix;
          homeProfile = ./home/profiles/main.nix;
          extraSystemModules = [ sops-nix.nixosModules.sops ];
          extraHomeModules = [
            nixCats.homeModule
            self.homeModules.godot
          ];
        };

        wsl = mkSystem {
          hostname = "wsl";
          username = "nixos";
          hostModule = ./hosts/profiles/wsl/configuration.nix;
          homeProfile = ./home/profiles/wsl.nix;
          extraSystemModules = [ nixos-wsl.nixosModules.default ];
          extraHomeModules = [ nixCats.homeModule ];
        };
      };
    };
}
