{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    authorized-keys = {
      # replace with yours how you want (can be /home/you/.ssh/id_rsa.pub)
      url = "https://github.com/karitham.keys";
      flake = false;
    };
  };
  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system: rec {
      nixosConfigurations = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
        };
        modules = [
          # system
          ({ ... }: {
            services.openssh.enable = true;
            users.users.root.openssh.authorizedKeys.keyFiles = [ inputs.authorized-keys ];
            nixpkgs.hostPlatform = system;
            system = { stateVersion = "23.11"; };
          })
          ./kubernetes.nix
        ];
      };

      defaultPackage = nixosConfigurations.config.system.build.vm;
    });

}
