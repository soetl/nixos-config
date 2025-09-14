{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.homeManagerModules.shell.direnv;
in {
  options.homeManagerModules.shell.direnv = {
    enable = mkEnableOption "direnv";
  };

  config = mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
