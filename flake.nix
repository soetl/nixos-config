{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs:
    with nixpkgs.lib; let
      inherit (self) outputs;

      args = [inputs outputs];
      system = "x86_64-linux";
      vars = import ./vars.nix;
      sharedModules = [{nixpgs.config.allowUnfree = lib.mkDefault true;}];

      forAllSystems = fn: genAttrs platforms.linux (system: fn nixpkgs.legacyPackages.${system});
    in {
      formatter = forAllSystems (pkgs: pkgs.alejandra);

      nixosModules = import ./modules/nixos.nix;

      nixosConfigurations = {
        desktop = nixosSystem {
          inherit system;
          specialArgs = args;
          modules = [./hosts/desktop.nix] ++ sharedModules;
        };
      };

      homeConfigurations = {
        "${vars.user.name}@${vars.hostname}" = homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = args;
          modules = [./homes/desktop.nix] ++ sharedModules;
        };
      };
    };
}
