{
  user = {
    name = "soetl";
    initialHashedPassword = "$7$GU..../....xRGneFIgUpGcd6NmUhJHg0$50oRh1wLvJZiSmbmvhWZUKcaRm7TmFwGLdOy75nss4A";

    extraGroups = [
      "audio"
      "docker"
      "i2c"
      "libvirtd"
      "networkmanager"
      "plugdev"
      "video"
      "wheel"
    ];
  };

  hostname = "nixos";

  disks.device = "/dev/disk/by-id/nvme-WD_BLACK_SN850X_4000GB_25033U801898";
}
