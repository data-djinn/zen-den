{
  description = "djinn's homelab";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    impermanence.url = "github:nix-community/impermanence/master";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixos-hardware,
    impermanence,
    ...
  } @ inputs: let
    inherit (self) outputs;
    forAllSystems = nixpkgs.lib.genAttrs [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
  in {
    # Your custom packages and modifications
    overlays = {
      default = import ./overlay {inherit inputs;};
    };

    # This instantiates nixpkgs for each system listed above
    # Allowing you to add overlays and configure it (e.g. allowUnfree)
    # packages= forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);
    homeManagerModules = import ./modules/home;

    nixosConfigurations = {
      icarus = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;}; # Pass flake inputs to our config
        modules = [
          nixos-hardware.nixosModules.common-pc-laptop-ssd
          ./machines/icarus
        ];
      };
      obelisk = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;}; # Pass flake inputs to our config
        modules = [
          ./machines/obelisk
          impermanence.nixosModules.impermanence
        ];
      };
      kraken = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          nixos-hardware.nixosModules.common-cpu-intel-cpu-only
          ./machines/kraken
        ];
      };
    };

    homeConfigurations = {
      "djinn@icarus" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-linux; # home-manager requires pkgs instance
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [
          ./modules/home
        ];
      };
    };
  };
}
