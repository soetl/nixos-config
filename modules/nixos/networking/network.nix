{
  config,
  lib,
  ...
}: let
  cfg = config.nixosModules.networking.network;
in
  with lib; {
    options.nixosModules.networking.network = {
      networkmanager.enable = mkEnableOption "NetworkManager";

      wifi = {
        enable = mkEnableOption "WiFi support";
        backend = mkOption {
          type = types.enum [
            "wpa_supplicant"
            "iwd"
          ];
          default = "iwd";
          description = "WiFi backend to use";
        };
      };

      firewall.enable = mkEnableOption "Firewall";
    };

    config = mkMerge [
      {
        networking = {inherit (cfg) firewall;};
      }

      (mkIf cfg.networkmanager.enable {
        networking.networkmanager = {
          inherit (cfg.networkmanager) enable;

          wifi.backend = mkIf cfg.wifi.enable cfg.wifi.backend;
        };
      })

      (mkIf (!cfg.networkmanager.enable && cfg.wifi.enable && cfg.wifi.backend == "iwd") {
        networking.wireless = {
          enable = false;
          iwd.enable = true;
        };
      })

      (mkIf (!cfg.networkmanager.enable && cfg.wifi.enable && cfg.wifi.backend == "wpa_supplicant") {
        networking.wireless = {
          enable = true;
          iwd.enable = false;
        };
      })

      {
        assertions = [
          {
            assertion = !(cfg.networkmanager.enable && cfg.wifi.enable) || cfg.wifi.backend != null;
            message = "nixosModules.core.networking: WiFi backend must be specified when WiFi is enabled";
          }
        ];
      }
    ];
  }
