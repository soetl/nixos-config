{device, ...}: {
  btrfs = import ./templates/btrfs.nix {inherit device;};
}
