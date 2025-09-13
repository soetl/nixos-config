{
  config,
  lib,
  inputs,
  ...
}: let
  cfg = config.nixosModules.hardware.disks;
  templates = import ./disks/templates.nix {inherit (cfg) device;};
in
  with lib; {
    imports = [
      inputs.disko.nixosModules.disko
    ];

    options.nixosModules.hardware.disks = {
      enable = mkEnableOption "Disks management via Disko";

      device = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Device to manage";
      };

      template = mkOption {
        type = types.nullOr types.enum [
          "btrfs"
        ];
        default = "none";
        description = "Disk template for Disko";
      };

      config = mkOption {
        type = types.nullOr types.attrs;
        default = null;
        description = "Configuration for Disko";
      };
    };

    config = mkIf cfg.enable {
      assertions = [
        {
          assertion = !(cfg.template == null && cfg.config == null);
          message = "nixosModules.core.disks.config must be set when template is null";
        }
        {
          assertion = !(cfg.template != null && cfg.device == null);
          message = "nixosModules.core.disks.device must be specified when not using custom config";
        }
      ];

      disko =
        {
          "btrfs" = templates.btrfs.disko;
          null = cfg.config.disko or {};
        }
      ."${cfg.template}" or {
        };
    };
  }
