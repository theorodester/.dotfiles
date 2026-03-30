{ inputs, config, pkgs, systemSettings, userSettings, ... }:

{
  imports = [ ../../modules/monitors.nix ];

  monitors = [{
    name = "DP-5";
    primary = true;
    width = 3440;
    height = 1440;
    refreshRate = 174.963;
    position = "0x0";
    enabled = true;
    scale = "1";
  }];

  networking.hostName = "conceivably-a-shark";

  hardware = {
    nvidia = {
      open = false; # not needed for < 50 series
      # make sure correct Bus ID for system! Can run: lspci
      prime = {
        # sync.enable = true; # might be good when plugged into external monitor? 
        nvidiaBusId = "PCI:1:0:0";
        intelBusId = "PCI:0:2:0";
      };
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
