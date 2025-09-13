{
  hardware = import ./nixos/hardware.nix;
  networking = import ./nixos/networking.nix;
  peripherals = import ./nixos/peripherals.nix;
  system = import ./nixos/system.nix;
}
