{ inputs, config, pkgs, systemSettings, userSettings, ... }: {
  imports = [ ../../modules/monitors.nix ];

  monitors = [{
    name = "DP-3";
    primary = true;
    width = 3440;
    height = 1440;
    refreshRate = 174.963;
    position = "0x0";
    enabled = true;
    scale = "1";
  }];

  networking.hostName = "plausibly-a-shark";

  hardware = {
    nvidia = {
      open = true; # needed for 50 series
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
