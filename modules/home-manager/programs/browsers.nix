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

        policies = {
          # Privacy & Security
          DisableTelemetry = true;
          DisableFirefoxStudies = true;
          EnableTrackingProtection = {
            Value = true;
            Locked = true;
            Cryptomining = true;
            Fingerprinting = true;
          };

          # Account & Services
          DisableFirefoxAccounts = true;
          DisableAccounts = true;
          DisablePocket = true;

          # Search
          SearchEngines = {
            Default = "DuckDuckGo";
            PreventInstalls = true;
          };

          # UI & UX
          DisplayBookmarksToolbar = "never"; # alternatives: "always" or "newtab"
          DisplayMenuBar = "default-off"; # alternatives: "always", "never" or "default-on"
          SearchBar = "unified"; # alternative: "separate"

          # Setup & Onboarding
          OverrideFirstRunPage = "";
          OverridePostUpdatePage = "";
          NoDefaultBookmarks = true;
          DontCheckDefaultBrowser = true;

          # Extensions
          ExtensionSettings = with builtins; let
            extension = shortId: uuid: {private_browsing ? false}: {
              name = uuid;
              value = {
                install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/${shortId}/latest.xpi";
                installation_mode = "normal_installed";
                private_browsing = private_browsing;
              };
            };
          in
            listToAttrs [
              (extension "1password-x-password-manager" "{d634138d-c276-4fc8-924b-40a0ea21d284}" {private_browsing = true;})
              (extension "ublock-origin" "uBlock0@raymondhill.net" {private_browsing = true;})
              (extension "sponsorblock" "sponsorBlocker@ajay.app" {})
              (extension "proton-vpn-firefox-extension" "vpn@proton.ch" {private_browsing = true;})
              (extension "steam-database" "firefox-extension@steamdb.info" {})
              (extension "protondb-for-steam" "{30280527-c46c-4e03-bb16-2e3ed94fa57c}" {})
              (extension "shikimori-player-extension" "{d91c4cff-9c1d-47dc-89fc-19a5ae175813}" {private_browsing = true;})
              (extension "shikicinema" "{78e6c1a5-0b68-4e13-a0ac-f3a7597cf220}" {private_browsing = true;})
              (extension "traduzir-paginas-web" "{036a55b4-5e72-4d05-a06c-cba2dfcc134a}" {private_browsing = true;})
              (extension "videospeed" "{7be2ba16-0f1e-4d93-9ebc-5164397477a9}" {private_browsing = true;})
              (extension "auto-tab-discard" "{c2c003ee-bd69-42a2-b0e9-6f34222cb046}" {private_browsing = true;})
              (extension "betterttv" "firefox@betterttv.net" {})
              # (extension "_____" "_____")
            ];
        };

        profiles.default = {
          isDefault = true;

          settings = {
            # General
            "general.autoScroll" = true;

            # Startup
            "browser.startup.page" = 3;

            # Extensions & Services
            "extensions.pocket.enabled" = false;

            # About & Config
            "browser.aboutConfig.showWarning" = false;

            # New Tab Page
            "browser.newtabpage.activity-stream.trendingSearch.defaultSearchEngine" = "DuckDuckGo";
            "browser.newtabpage.activity-stream.default.sites" = "";
            "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
            "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
          };
        };
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
