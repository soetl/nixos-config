{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.homeManagerModules.programs.browsers.firefox;
in {
  options.homeManagerModules.programs.browsers.firefox = {
    enable = mkEnableOption "Firefox";
    nightly = mkEnableOption "Firefox Nightly";

    policies = mkOption {
      type = types.attrs;
      default = {
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
        DisplayBookmarksToolbar = "never";
        DisplayMenuBar = "default-off";
        SearchBar = "unified";

        # Setup & Onboarding
        OverrideFirstRunPage = "";
        OverridePostUpdatePage = "";
        NoDefaultBookmarks = true;
        DontCheckDefaultBrowser = true;
      };
      description = "Firefox policies configuration";
    };

    extensions = mkOption {
      type = types.listOf (types.submodule {
        options = {
          shortId = mkOption {
            type = types.str;
            description = "Extension short identifier from addons.mozilla.org";
          };
          uuid = mkOption {
            type = types.str;
            description = "Extension UUID";
          };
          extensionSettings = mkOption {
            type = types.submodule {
              options = {
                private_browsing = mkOption {
                  type = types.bool;
                  default = false;
                  description = "Enable extension in private browsing mode";
                };
                installation_mode = mkOption {
                  type = types.enum ["normal_installed" "force_installed" "blocked"];
                  default = "normal_installed";
                  description = "Extension installation mode";
                };
                permissions = mkOption {
                  type = types.listOf types.str;
                  default = [];
                  description = "List of permissions to grant to the extension";
                };
              };
            };
            default = {};
            description = "Extension-specific settings";
          };
        };
      });
      default = [
        {
          shortId = "1password-x-password-manager";
          uuid = "{d634138d-c276-4fc8-924b-40a0ea21d284}";
          extensionSettings.private_browsing = true;
        }
        {
          shortId = "ublock-origin";
          uuid = "uBlock0@raymondhill.net";
          extensionSettings.private_browsing = true;
        }
        {
          shortId = "sponsorblock";
          uuid = "sponsorBlocker@ajay.app";
        }
        {
          shortId = "proton-vpn-firefox-extension";
          uuid = "vpn@proton.ch";
          extensionSettings.private_browsing = true;
        }
        {
          shortId = "steam-database";
          uuid = "firefox-extension@steamdb.info";
        }
        {
          shortId = "protondb-for-steam";
          uuid = "{30280527-c46c-4e03-bb16-2e3ed94fa57c}";
        }
        {
          shortId = "shikimori-player-extension";
          uuid = "{d91c4cff-9c1d-47dc-89fc-19a5ae175813}";
          extensionSettings.private_browsing = true;
        }
        {
          shortId = "shikicinema";
          uuid = "{78e6c1a5-0b68-4e13-a0ac-f3a7597cf220}";
          extensionSettings.private_browsing = true;
        }
        {
          shortId = "traduzir-paginas-web";
          uuid = "{036a55b4-5e72-4d05-a06c-cba2dfcc134a}";
          extensionSettings.private_browsing = true;
        }
        {
          shortId = "videospeed";
          uuid = "{7be2ba16-0f1e-4d93-9ebc-5164397477a9}";
          extensionSettings.private_browsing = true;
        }
        {
          shortId = "auto-tab-discard";
          uuid = "{c2c003ee-bd69-42a2-b0e9-6f34222cb046}";
          extensionSettings.private_browsing = true;
        }
        {
          shortId = "betterttv";
          uuid = "firefox@betterttv.net";
        }
      ];
      description = "List of Firefox extensions to install";
    };

    settings = mkOption {
      type = types.attrs;
      default = {
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
      description = "Firefox profile settings";
    };
  };

  config = mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      package =
        if cfg.nightly
        then inputs.firefox.packages.${pkgs.system}.firefox-nightly-bin
        else pkgs.firefox;

      policies =
        cfg.policies
        // {
          # Extensions
          ExtensionSettings = with builtins; let
            extension = shortId: uuid: {
              private_browsing ? false,
              installation_mode ? "normal_installed",
              permissions ? [],
            }: {
              name = uuid;
              value =
                {
                  install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/${shortId}/latest.xpi";
                  installation_mode = installation_mode;
                  private_browsing = private_browsing;
                }
                // (
                  if permissions != []
                  then {inherit permissions;}
                  else {}
                );
            };
          in
            listToAttrs (map (ext:
              extension ext.shortId ext.uuid {
                private_browsing = ext.extensionSettings.private_browsing;
                installation_mode = ext.extensionSettings.installation_mode;
                permissions = ext.extensionSettings.permissions;
              })
            cfg.extensions);
        };

      profiles.default = {
        isDefault = true;
        settings = cfg.settings;
      };
    };
  };
}
