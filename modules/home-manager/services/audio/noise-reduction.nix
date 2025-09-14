{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.homeManagerModules.services.audio.noiseReduction;
  aliases = config.homeManagerModules.shell.aliases;
in {
  options.homeManagerModules.services.audio.noiseReduction = {
    enable = mkEnableOption "PipeWire noise reduction with RNNoise";

    rnnoise = {
      vadThreshold = mkOption {
        type = types.float;
        default = 60.0;
        description = "Voice Activity Detection threshold (%)";
      };

      vadGracePeriod = mkOption {
        type = types.int;
        default = 200;
        description = "VAD Grace Period in milliseconds";
      };

      retroactiveVadGrace = mkOption {
        type = types.int;
        default = 0;
        description = "Retroactive VAD Grace in milliseconds";
      };
    };

    autostart = mkOption {
      type = types.bool;
      default = true;
      description = "Automatically start the noise reduction filter on login";
    };

    advanced = {
      bufferSize = mkOption {
        type = types.int;
        default = 1024;
        description = "Audio buffer size for processing";
      };

      channels = mkOption {
        type = types.enum [
          "mono"
          "stereo"
        ];
        default = "mono";
        description = "Audio channel configuration";
      };
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Additional PipeWire filter configuration";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      rnnoise-plugin
    ];

    xdg.configFile."pipewire/pipewire.conf.d/99-noise-reduction.conf".text = ''
      context.modules = [
        {
          name = libpipewire-module-filter-chain
          args = {
            node.description = "Noise Canceling source"
            media.name = "Noise Canceling source"
            filter.graph = {
              nodes = [
                {
                  type = ladspa
                  name = rnnoise
                  plugin = "${pkgs.rnnoise-plugin}/lib/ladspa/librnnoise_ladspa.so"
                  label = noise_suppressor_${cfg.advanced.channels}
                  control = {
                    "VAD Threshold (%)" = ${toString cfg.rnnoise.vadThreshold}
                    "VAD Grace Period (ms)" = ${toString cfg.rnnoise.vadGracePeriod}
                    "Retroactive VAD Grace (ms)" = ${toString cfg.rnnoise.retroactiveVadGrace}
                  }
                }
              ]
            }
            capture.props = {
              node.name = "capture.rnnoise_source"
              node.passive = true
              audio.rate = 48000
              audio.channels = ${
        if cfg.advanced.channels == "stereo"
        then "2"
        else "1"
      }
              node.latency = "${toString cfg.advanced.bufferSize}/48000"
            }
            playback.props = {
              node.name = "rnnoise_source"
              media.class = Audio/Source
              audio.rate = 48000
              audio.channels = ${
        if cfg.advanced.channels == "stereo"
        then "2"
        else "1"
      }
            }
            ${cfg.extraConfig}
          }
        }
      ]
    '';

    # Systemd user service for autostart
    systemd.user.services.pipewire-noise-reduction = mkIf cfg.autostart {
      Unit = {
        Description = "PipeWire Noise Reduction";
        After = ["pipewire.service"];
        Requires = ["pipewire.service"];
      };

      Service = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.pipewire}/bin/pw-cli load-module libpipewire-module-filter-chain";
        ExecStop = "${pkgs.pipewire}/bin/pw-cli unload-module libpipewire-module-filter-chain";
      };

      Install = {
        WantedBy = ["pipewire.service"];
      };
    };

    homeManagerModules.shell.aliases = mkMerge [
      {
        noise-on = "systemctl --user start pipewire-noise-reduction";
        noise-off = "systemctl --user stop pipewire-noise-reduction";
        noise-restart = "systemctl --user restart pipewire-noise-reduction";
        noise-status = "pw-cli info all | grep -i rnnoise";
        noise-logs = "journalctl --user -u pipewire-noise-reduction -f";
      }
    ];

    home.sessionVariables = {
      PIPEWIRE_NOISE_REDUCTION =
        if cfg.enable
        then "1"
        else "0";
    };
  };
}
