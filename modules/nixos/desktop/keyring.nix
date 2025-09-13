{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixosModules.desktop.keyring;
in {
  options.nixosModules.desktop.keyring.gnome.enable = mkEnableOption "Gnome Keyring";

  config = {
    services.gnome.gnome-keyring.enable = cfg.gnome.enable;
  };
}
