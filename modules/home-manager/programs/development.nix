{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.homeManagerModules.programs.development;
in {
  options.homeManagerModules.programs.development = {
    git = {
      enable = mkEnableOption "Git";

      credential = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable Git Credential Manager";
        };

        entries = mkOption {
          type = types.attrsOf (types.attrsOf types.str);
          default = {
            "https://github.com".username = "soetl";
          };
          description = "Git credential helper entries organized by URL";
        };
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = mkIf cfg.credential.enable (with pkgs; [
        git-credential-manager
        git-crypt
        pre-commit
      ]);

      programs.git = {
        enable = true;
        userName = vars.user.name;
        userEmail = vars.user.email;

        extraConfig = {
          init.defaultBranch = "main";

          pull.rebase = false;
          push.autoSetupRemote = true;

          credential = mkIf cfg.credential.enable ({
              helper = "manager";
              credentialStore = "cache";
            }
            // cfg.credential.entries);
        };

        delta.enable = true;
      };
    }
  ]);
}
