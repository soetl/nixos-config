{
  pkgs,
  inputs,
  config,
  lib,
  ...
}: let
  cfg = config.nixosModules.system.secureBoot;
in
  with lib; {
    imports = [
      inputs.lanzaboote.nixosModules.lanzaboote
    ];

    options.nixosModules.system.secureBoot.enable = mkEnableOption "Secure Boot via Lanzaboote and sbctl";

    config = mkIf cfg.enable {
      environment.systemPackages = [
        pkgs.sbctl
      ];

      boot.loader.systemd-boot.enable = lib.mkForce false;

      boot.lanzaboote = {
        enable = true;
        pkiBundle = "/var/lib/sbctl";
      };
    };
  }
