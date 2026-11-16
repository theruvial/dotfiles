# Performance tuning for a MacBook 7,1 (mid-2010 13" unibody):
# Core 2 Duo, NVIDIA GeForce 320M (nouveau), SATA disk, 8 GB RAM.
#
# Use it by adding one line to /etc/nixos/configuration.nix:
#   imports = [ ./macbook-7-1.nix ];
#
# Every block is independent. Delete any you do not want.
{ config, lib, pkgs, ... }:

{
  hardware.enableRedistributableFirmware = true;

  # --- Memory ----------------------------------------------------------------
  # Compressed RAM swap is much faster than swapping to a spinning disk.
  zramSwap = {
    enable = true;
    memoryPercent = 50; # about 4 GB of compressed swap on 8 GB
  };

  boot.kernel.sysctl = {
    # With zram, swapping early is cheap, so a high swappiness is the right choice.
    "vm.swappiness" = 100;
    "vm.vfs_cache_pressure" = 50;
  };

  # Kill the biggest process before the machine thrashes for minutes.
  services.earlyoom = {
    enable = true;
    freeMemThreshold = 5; # percent of RAM still free before acting
  };

  # --- Storage ---------------------------------------------------------------
  # noatime stops a disk write on every file read.
  fileSystems."/".options = [ "noatime" ];

  services.fstrim.enable = true; # discard unused blocks (for SSDs)

  services.journald.settings.Journal.SystemMaxUse = "200M";

  # --- CPU and temperature ---------------------------------------------------
  # The Core 2 CPU throttles when hot. mbpfan drives the fans with applesmc.
  services.mbpfan.enable = true;

  powerManagement.cpuFreqGovernor = "schedutil";

  # --- Services you probably do not need -------------------------------------
  services.printing.enable = false;
  services.avahi.enable = false;
  # hardware.bluetooth.enable = false; # uncomment if you do not use Bluetooth

  # --- Nix builds on 2 cores and 8 GB ----------------------------------------
  # Building from source with many jobs swaps heavily on this hardware.
  # Binary caches (the default) do most of the work anyway.
  nix.settings = {
    max-jobs = 1;
    cores = 2;
  };

  nix.optimise.automatic = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  documentation.nixos.enable = false;
  documentation.doc.enable = false;

  # --- Graphics note ---------------------------------------------------------
  # The GeForce 320M uses the open nouveau driver. Nouveau cannot change the
  # GPU clock on this chip, so the GPU stays slow. Keep effects light:
  # use picom with the xrender backend, or run without a compositor.

  # --- Optional: i3 session (the dotfiles in this repo are for i3) -----------
  # Uncomment if you want i3 as your session, and remove other desktop options.
  # services.xserver = {
  #   enable = true;
  #   windowManager.i3.enable = true;
  # };
  # services.xserver.displayManager.lightdm.enable = true;
  # services.displayManager.defaultSession = "none+i3";

  # --- Optional: Broadcom Wi-Fi ----------------------------------------------
  # Check your card with: lspci -nn | grep -i network
  # If it is Broadcom and Wi-Fi is unreliable, enable the wl driver.
  # boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
  # boot.kernelModules = [ "wl" ];
  # boot.blacklistedKernelModules = [ "b43" "bcma" "ssb" ];
}
