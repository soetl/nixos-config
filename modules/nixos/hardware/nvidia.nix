{
  config,
  lib,
  ...
}: let
  cfg = config.nixosModules.hardware.nvidia;
in
  with lib; {
    options.nixosModules.hardware.nvidia = {
      enable = mkEnableOption "NVIDIA drivers";

      package = mkOption {
        type = types.package;
        default = config.boot.kernelPackages.nvidiaPackages.latest;
        description = "NVIDIA package to install";
      };
    };

    config = mkIf cfg.enable {
      services.xserver.videoDrivers = ["nvidia"];

      hardware.nvidia = {
        inherit (cfg) package;

        open = true;
        modesetting.enable = true;
        powerManagement.enable = true;
        powerManagement.finegrained = false;
        nvidiaSettings = true;
      };

      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };
    };
  }
