{
  vars,
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

  config = mkMerge [
    (mkIf
      cfg.git.enable
      {
        home.packages = with pkgs;
          [
            git-crypt
            pre-commit
          ]
          ++ optional cfg.git.credential.enable git-credential-manager;

        programs.git = {
          enable = true;
          userName = vars.user.name;
          userEmail = vars.user.email;

          extraConfig = {
            init.defaultBranch = "main";

            pull.rebase = false;
            push.autoSetupRemote = true;

            credential = mkIf cfg.git.credential.enable ({
                helper = "manager";
                credentialStore = "cache";
              }
              // cfg.git.credential.entries);
          };

          delta.enable = true;
        };
      })
  ];
}
