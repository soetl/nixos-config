{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs:
    with nixpkgs.lib; let
      inherit (self) outputs;

      system = "x86_64-linux";
      vars = import ./vars.nix;
      specialArgs = {inherit inputs outputs vars;};
      sharedModules = [{nixpkgs.config.allowUnfree = mkDefault true;}];

      forAllSystems = fn: genAttrs platforms.linux (system: fn nixpkgs.legacyPackages.${system});
    in {
      formatter = forAllSystems (pkgs: pkgs.alejandra);

      nixosModules = import ./modules/nixos.nix;
      homeManagerModules = import ./modules/home-manager.nix;

      nixosConfigurations = {
        desktop = nixosSystem {
          inherit system specialArgs;
          modules = [./hosts/desktop.nix] ++ sharedModules;
        };
        desktopInstall = nixosSystem {
          inherit system specialArgs;
          modules = [./hosts/desktop-install.nix];
        };
      };

      homeConfigurations = {
        "${vars.user.name}@${vars.hostname}" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = specialArgs;
          modules = [./homes/desktop.nix] ++ sharedModules;
        };
      };
    };
}
