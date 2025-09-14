{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.homeManagerModules.shell.starship;
  fish = config.homeManagerModules.shell.fish;
in {
  options.homeManagerModules.shell.starship = {
    enable = mkEnableOption "Starship";

    configFile = mkOption {
      type = types.path;
      default = ./starship/defaultConfig.toml;
      description = "Path to starship configuration file";
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Additional TOML configuration to append";
    };
  };

  config = mkIf cfg.enable {
    programs.starship = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = fish.enable;
    };

    xdg.configFile."starship.toml" = {
      text = builtins.readFile cfg.configFile + cfg.extraConfig;
    };
  };
}
