{device, ...}: {
  btrfs = import ./disks/templates/btrfs.nix {inherit device;};
}
