{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.homeManagerModules.programs.browsers;
  firefoxCfg = config.homeManagerModules.programs.browsers.firefox;
  chromiumCfg = config.homeManagerModules.programs.browsers.chromium;
in {
  imports = [
    ./browsers/firefox.nix
    ./browsers/chromium.nix
  ];

  options.homeManagerModules.programs.browsers = {
    defaultBrowser = mkOption {
      type = types.nullOr (types.enum ["firefox" "chromium"]);
      default = null;
      description = ''
        Set the default browser for the system.
        Options: "firefox", "chromium", or null (no default set).
      '';
    };
  };

  config = mkMerge [
    # Set Firefox as default browser
    (mkIf (cfg.defaultBrowser == "firefox") {
      home.sessionVariables = {
        BROWSER =
          if firefoxCfg.nightly
          then "${inputs.firefox.packages.${pkgs.system}.firefox-nightly-bin}/bin/firefox"
          else "${pkgs.firefox}/bin/firefox";
      };

      xdg.mimeApps.defaultApplications = let
        desktopFile =
          if firefoxCfg.nightly
          then "firefox-nightly.desktop"
          else "firefox.desktop";
      in {
        "text/html" = desktopFile;
        "x-scheme-handler/http" = desktopFile;
        "x-scheme-handler/https" = desktopFile;
        "x-scheme-handler/about" = desktopFile;
        "x-scheme-handler/unknown" = desktopFile;
      };
    })

    # Set Chromium as default browser
    (mkIf (cfg.defaultBrowser == "chromium") {
      home.sessionVariables = {
        BROWSER =
          if chromiumCfg.ungoogled
          then "${pkgs.ungoogled-chromium}/bin/chromium"
          else "${pkgs.chromium}/bin/chromium-browser";
      };

      xdg.mimeApps.defaultApplications = {
        "text/html" = "chromium-browser.desktop";
        "x-scheme-handler/http" = "chromium-browser.desktop";
        "x-scheme-handler/https" = "chromium-browser.desktop";
        "x-scheme-handler/about" = "chromium-browser.desktop";
        "x-scheme-handler/unknown" = "chromium-browser.desktop";
      };
    })
  ];
}
