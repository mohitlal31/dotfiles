{
  description = "mohitlal's macOS setup (nix-darwin + home-manager)";

  inputs = {
    # Pinned to the 26.05 release line (matches your macOS-current toolchain).
    # Bump these tags + `nix flake update` to move to a newer release.
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";

    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager }:
    let
      # The one line to change on a different machine (your macOS username).
      # bootstrap.sh checks this matches `whoami` before the first build.
      user = "mohitlal";
    in
    {
      darwinConfigurations."mac" = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit user; };
        modules = [
          ./configuration.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # First switch: back up any file we replace (e.g. your existing
            # ~/.zshrc Stow symlink) to <name>.before-nix instead of erroring.
            home-manager.backupFileExtension = "before-nix";
            home-manager.extraSpecialArgs = { inherit user; };
            home-manager.users.${user} = import ./home.nix;
          }
        ];
      };
    };
}
