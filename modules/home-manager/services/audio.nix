{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.homeManagerModules.services.audio;
in {
  imports = [
    ./audio/noise-reduction.nix
  ];

  options.homeManagerModules.services.audio = {
    qpwgraph = mkEnableOption "qpwgraph";

    pavucontrol = {
      enable = mkEnableOption "pavucontrol";

      qt = mkOption {
        type = types.bool;
        default = true;
        description = "Enable pavucontrol with Qt support";
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.qpwgraph {
      home.packages = with pkgs; [
        qpwgraph
      ];
    })

    (mkIf cfg.pavucontrol.enable {
      home.packages =
        (optional cfg.pavucontrol.qt pkgs.pavucontrol-qt)
        ++ optional (!cfg.pavucontrol.qt) pkgs.pavucontrol;
    })
  ];
}
