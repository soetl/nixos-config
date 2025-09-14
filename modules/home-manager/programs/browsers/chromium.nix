{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.homeManagerModules.programs.browsers.chromium;
in {
  options.homeManagerModules.programs.browsers.chromium = {
    enable = mkEnableOption "Chromium";
    ungoogled = mkEnableOption "Chromium Ungoogled";
  };

  config = mkIf cfg.enable {
    programs.chromium = {
      enable = true;
      package =
        if cfg.ungoogled
        then pkgs.ungoogled-chromium
        else pkgs.chromium;
    };
  };
}
