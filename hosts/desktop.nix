{
  outputs,
  vars,
  pkgs,
  lib,
  config,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")

    outputs.nixosModules.hardware
    outputs.nixosModules.system
    outputs.nixosModules.networking
    outputs.nixosModules.peripherals
    outputs.nixosModules.desktop
  ];

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

    initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "thunderbolt"
      "ahci"
      "usb_storage"
      "usbhid"
      "sd_mod"
    ];
    initrd.kernelModules = [];
    kernelModules = ["kvm-amd"];
    extraModulePackages = [];
    extraModprobeConfig = "";

    tmp.cleanOnBoot = true;
  };

  services.fstrim.enable = lib.mkDefault true;
  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  nix = {
    channels.enable = false;

    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
      dates = "weekly";
    };

    substituters = ["https://hyprland.cachix.org"];
    trusted-substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };

  nixosModules.hardware = {
    disks = {
      inherit (vars.disks) device;
      enable = true;
      template = "btrfs";
    };

    nvidia.enable = true;
  };

  nixosModules.system = {
    bootLoader.systemd-boot.enable = true;
    secureBoot.enable = true;
  };

  security.polkit.enable = true;

  time.timeZone = "Europe/Warsaw";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  nixosModules.networking.network = {
    networkmanager.enable = true;
    wifi.enable = true;
    firewall.enable = true;
  };
  hardware.bluetooth.enable = true;

  nixosModules.peripherals.audio.enable = true;

  users.users."${vars.user.name}" = let
    ifGroupExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
  in {
    isNormalUser = true;
    initialHashedPassword = vars.user.initialHashedPassword;
    extraGroups = ifGroupExist vars.user.extraGroups;
    packages = [pkgs.home-manager];
  };
  users.mutableUsers = true;

  nixosModules.desktop = {
    desktopManager.sddm = {
      enable = true;
      theme = {
        enable = true;
        package = pkgs.sddm-astronaut;
        path = "${pkgs.sddm-astronaut}/share/sddm/themes/sddm-astronaut-theme";

        extraPackages = with pkgs; [
          kdePackages.qtsvg
          kdePackages.qtmultimedia
          kdePackages.qtvirtualkeyboard
        ];
      };
    };

    kde.enable = true;
    hyprland.enable = true;

    keyring.gnome.enable = true;
  };

  programs._1password.enable = true;
  programs._1password-gui.enable = true;
}
