{
  config,
  lib,
  ...
}: let
  cfg = config.nixosModules.desktop.desktopManager.sddm;
in
  with lib; {
    options.nixosModules.desktop.desktopManager.sddm = {
      enable = mkEnableOption "SDDM";
      theme = {
        enable = mkEnableOption "SDDM Theme";

        package = mkOption {
          type = types.nullOr types.package;
          default = null;
          description = "Package containing the SDDM theme";
        };

        extraPackages = mkOption {
          type = types.listOf types.package;
          default = [];
          description = "Extra packages to include in the SDDM theme";
        };

        path = mkOption {
          type = types.str;
          default = "";
          description = "Path to the SDDM theme";
        };
      };
    };

    config = mkIf cfg.enable {
      environment.systemPackages =
        []
        ++ optionals cfg.theme.enable [cfg.theme.package]
        ++ optionals cfg.theme.enable cfg.theme.extraPackages;

      services.displayManager.sddm = {
        enable = true;
        wayland.enable = true;
        enableHidpi = true;
        theme = mkIf cfg.theme.enable cfg.theme.path;
      };
    };
  }
