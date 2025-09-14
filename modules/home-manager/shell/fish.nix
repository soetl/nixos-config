{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.homeManagerModules.shell.fish;
in {
  options.homeManagerModules.shell.fish = {
    enable = mkEnableOption "Fish";

    plugins = {
      enable = mkEnableOption "Fish Plugins";

      list = mkOption {
        type = types.listOf types.str;
        default = [
          "tide"
          "fzf-fish"
        ];
        description = "List of Fish plugins to install";
      };
    };
  };

  config = mkIf cfg.enable {
    programs.fish = {
      enable = true;

      plugins = mkIf cfg.plugins.enable (
        map (plugin: {
          name = plugin;
          src = pkgs.fishPlugins.${plugin}.src or (throw "Fish plugin '${plugin}' not found in nixpkgs");
        })
        cfg.plugins.list
      );
    };
  };
}
