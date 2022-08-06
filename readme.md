## Installation

Prerequisites:
- [NixOS installed and running](https://nixos.org/manual/nixos/stable/index.html#ch-installation)
- [Flakes enabled](https://nixos.wiki/wiki/flakes)
- Root access

Clone the repo and cd into it:

```bash
git clone https://github.com/codanael/nixos ~/.config/nixos && cd ~/.config/nixos
```

First, create a hardware configuration for your system:

```bash
sudo nixos-generate-config
```

You can then copy this to a the `hosts/` directory (note: change `yourComputer` with whatever you want):

```
mkdir hosts/yourComputer
cp /etc/nixos/hardware-configuration.nix ~/.config/nixos/hosts/yourComputer/
```

You can either add or create your own output in `flake.nix`, by following this template:
```nix
nixosConfigurations = {
    # Now, defining a new system is can be done in one line
    #                                Architecture   Hostname
    laptop = mkSystem inputs.nixpkgs "x86_64-linux" "laptop";
    desktop = mkSystem inputs.nixpkgs "x86_64-linux" "desktop";
    # ADD YOUR COMPUTER HERE! (feel free to remove mine)
    yourComputer = mkSystem inputs.nixpkgs "x86_64-linux" "yourComputer";
};
```

Next, create `hosts/yourComputer/user.nix`, a configuration file for your system for any modules you want to enable:
```nix
{ config, lib, inputs, ...}:

{
    imports = [ ../../modules/default.nix ];
    config.modules = {
        # gui
        hyprland.enable = true;

        # cli
        nvim.enable = true;

        # system
        xdg.enable = true;
    };
}
```
The above config installs and configures hyprland, nvim, and xdg user directories. Each config is modularized so you don't have to worry about having to install the software alongside it, since the module does it for you. Every available module can be found in the `modules` directory.

Lastly, build the configuration with 

```bash
sudo nixos-rebuild switch --flake .#yourComputer
```

