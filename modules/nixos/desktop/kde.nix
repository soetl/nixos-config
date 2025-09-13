{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.nixosModules.desktop.kde;
in
  with lib; {
    options.nixosModules.desktop.kde.enable =
      mkEnableOption "KDE Plasma Desktop Environment";

    config = mkIf cfg.enable {
      services.desktopManager.plasma6.enable = true;
      environment.plasma6.excludePackages = [pkgs.kdePackages.sddm];
    };
  }
