{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.homeManagerModules.programs.browsers;
in {
  options.homeManagerModules.programs.browsers = {
    firefox = {
      enable = mkEnableOption "Firefox";
      nightly = mkEnableOption "Firefox Nightly";
    };

    chromium = {
      enable = mkEnableOption "Chromium";
      ungoogled = mkEnableOption "Chromium Ungoogled";
    };
  };

  config = mkMerge [
    (mkIf cfg.firefox.enable {
      programs.firefox = {
        enable = true;
        package =
          if cfg.firefox.nightly
          then inputs.firefox.packages.${pkgs.system}.firefox-nightly-bin
          else pkgs.firefox;
      };
    })

    (mkIf cfg.chromium.enable {
      programs.chromium = {
        enable = true;
        package =
          if cfg.chromium.ungoogled
          then pkgs.ungoogled-chromium
          else pkgs.chromium;
      };
    })
  ];
}
