{
  outputs,
  vars,
  pkgs,
  lib,
  ...
}:
with lib; {
  imports = [
    outputs.homeManagerModules.desktop
    outputs.homeManagerModules.programs
    outputs.homeManagerModules.services
    outputs.homeManagerModules.shell
  ];

  home = {
    username = vars.user.name;
    homeDirectory = "/home/${vars.user.name}";
    shell.enableShellIntegration = true;

    packages = with pkgs; [
      chromium

      zed-editor
      vscode

      telegram-desktop
      discord

      kdePackages.polkit-kde-agent-1
    ];

    stateVersion = "25.11";
  };

  systemd.user.services.polkit-kde-authentication-agent-1 = {
    Unit = {
      Description = "polkit-kde-authentication-agent-1";
      Wants = ["graphical-session.target"];
      After = ["graphical-session.target"];
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  homeManagerModules.shell = {
    aliases = mkMerge [{zed = "zeditor";}];
    fish.enable = true;
    starship.enable = true;
    direnv.enable = true;
  };

  homeManagerModules.programs.development.git.enable = true;

  homeManagerModules.services.audio.noiseReduction = {
    enable = true;
    autostart = true;
  };

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };
}
