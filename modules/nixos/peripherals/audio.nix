{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.nixosModules.peripherals.audio;
in
  with lib; {
    options.nixosModules.peripherals.audio = {
      enable = mkEnableOption "Audio via Pipewire";

      alsa = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable ALSA";
        };

        support32Bit = mkOption {
          type = types.bool;
          default = true;
          description = "Enable ALSA 32-bit Support";
        };
      };

      jack = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable JACK";
        };
      };

      pulseaudio = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Install PulseAudio";
        };
      };
    };

    config = mkIf cfg.enable {
      environment.systemPackages = with pkgs;
        mkIf cfg.pulseaudio.enable [pulseaudio];

      services = {
        pipewire = {
          inherit (cfg) enable pulse jack alsa;

          wireplumber.enable = mkDefault true;
        };

        pulseaudio.enable = mkDefault false;
      };

      security.rtkit.enable = true;
    };
  }
