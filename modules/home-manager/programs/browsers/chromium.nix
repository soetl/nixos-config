{
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
      package = pkgs.chromium;
      extensions = [];

      commandLineArgs = [
        "--disable-sync"
        "--no-default-browser-check"
        "--no-first-run"
        "--disable-metrics"
        "--disable-metrics-reporting"
      ];
    };
  };
}
