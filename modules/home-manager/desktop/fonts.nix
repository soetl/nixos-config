{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.homeManagerModules.desktop.fonts;
in {
  options.homeManagerModules.desktop.fonts = {
    jetbrainsMonoNerd = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable JetBrains Mono Nerd Font";
      };
    };

    extraFonts = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Additional fonts to install";
    };

    terminalFont = mkOption {
      type = types.str;
      default = "JetBrainsMono Nerd Font";
      description = "Terminal font";
    };
  };

  config = {
    fonts.fontconfig.enable = true;

    home.packages = with pkgs;
      (optionals cfg.jetbrainsMonoNerd.enable [nerd-fonts.jetbrains-mono])
      ++ cfg.extraFonts;

    home.sessionVariables = {
      TERMINAL_FONT = cfg.terminalFont;
    };
  };
}
