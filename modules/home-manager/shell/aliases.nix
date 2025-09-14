{lib, ...}:
with lib; let
  aliases = config.homeManagerModules.shell.aliases;
in {
  options.homeManagerModules.shell.aliases = mkOption {
    type = types.attrsOf types.str;
    default = {
      vi = "nvim";
      vim = "nvim";
      ".." = "cd ..";
      "..." = "cd ../..";
    };
    description = "Aliases for the shell";
  };

  config = {
    home.shellAliases = aliases;
  };
}
