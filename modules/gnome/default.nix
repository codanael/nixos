{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.gnome;

in {
    # Enable the X11 windowing system.
    services.xserver.enable = true;

    # Enable the GNOME Desktop Environment.
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;

    # Configure keymap in X11
    services.xserver = {
      layout = "fr";
      xkbVariant = "";
    };
}
