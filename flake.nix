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

      mkSystem =
        {
          hostname,
          username,
          hostModule,
          homeProfile,
          extraModules ? [ ],
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit
              inputs
              configDir
              hostname
              username
              ;
          };
          modules = [
            hostModule
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "backup";
                overwriteBackup = true;
                sharedModules = [ nixCats.homeModule ];
                users.${username} = homeProfile;
                extraSpecialArgs = {
                  inherit
                    inputs
                    configDir
                    configHomeDir
                    editMode
                    ;
                  inherit hostname username;
                };
              };
            }
          ]
          ++ extraModules;
        };
    in
    {
      nixosConfigurations = {
        laptop = mkSystem {
          hostname = "laptop";
          username = "huedeane";
          hostModule = ./hosts/profiles/laptop/configuration.nix;
          homeProfile = ./home/profiles/main.nix;
        };

        wsl = mkSystem {
          hostname = "wsl";
          username = "nixos";
          hostModule = ./hosts/profiles/wsl/configuration.nix;
          homeProfile = ./home/profiles/wsl.nix;
          extraModules = [ nixos-wsl.nixosModules.default ];
        };
      };
    };
}
