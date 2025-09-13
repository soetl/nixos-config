{
  config,
  lib,
  ...
}: let
  cfg = config.nixosModules.desktop.hyprland;
in
  with lib; {
    options.nixosModules.desktop.hyprland = {
      enable = mkEnableOption "Hyprland";
    };

    config = mkIf cfg.enable {
      programs.hyprland.enable = true;

      xdg.portal = {
        enable = true;
        wlr.enable = true;
      };
    };
  }
