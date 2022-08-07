{ config, pkgs, inputs, ... }:

{
    programs.zsh.enable = true;

    # Laptop-specific packages (the other ones are installed in `packages.nix`)
    environment.systemPackages = with pkgs; [
        acpi tlp git
    ];

    # Install fonts
    fonts = {
        fonts = with pkgs; [
            jetbrains-mono
            roboto
            (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
        ];
        fontconfig.hinting.autohint = true;
    };

    # Nix settings, auto cleanup and enable flakes
    nix = {
        settings.auto-optimise-store = true;
        settings.allowed-users = [ "anael" ];
        gc = {
            automatic = true;
            dates = "weekly";
            options = "--delete-older-than 7d";
        };
        extraOptions = ''
            experimental-features = nix-command flakes
            keep-outputs = true
            keep-derivations = true
        '';
    };

    # Boot settings: clean /tmp/, latest kernel and enable bootloader
    boot = {
        cleanTmpDir = true;
        loader = {
        systemd-boot.enable = true;
        systemd-boot.editor = false;
        efi.canTouchEfiVariables = true;
        timeout = 3;
        };
    };

    # Set up locales (timezone and keyboard layout)
    time.timeZone = "Europe/Paris";
    i18n.defaultLocale = "en_US.UTF-8";
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "fr_FR.utf8";
      LC_IDENTIFICATION = "fr_FR.utf8";
      LC_MEASUREMENT = "fr_FR.utf8";
      LC_MONETARY = "fr_FR.utf8";
      LC_NAME = "fr_FR.utf8";
      LC_NUMERIC = "fr_FR.utf8";
      LC_PAPER = "fr_FR.utf8";
      LC_TELEPHONE = "fr_FR.utf8";
      LC_TIME = "fr_FR.utf8";
    };
    console = {
        font = "Lat2-Terminus16";
        keyMap = "fr";
    };

    # Set up user and enable sudo
    users.users.anael = {
        isNormalUser = true;
        extraGroups = [ "input" "wheel" "networkmanager" ];
        shell = pkgs.zsh;
        openssh.authorizedKeys.keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDaxmFvnF9smiZnDySxS5Coo4dMiUQ7nOIKx3Fk1jEMFZNpntKCV7MFdRDS3goc0Cx0GOHMhqgTOJKKb9CW1tzmPStSiz/72YeOpEC/tXnROFc4k+fc4cwZWEdr+eLIes3LCBuo1N/jtDVAApdgEuL6xNLqc2PqQG7MYIioz1kENpre5dGE9U4Bm7HsOQkaHzBmIBbdgyTq4vz5TvB5aYdI3qzzNMRuDaBpqU/eT08+R8zPAhjvYnpuq9y2kJf5YNU3mIUqnPjB1ivopZqLmLpz6/ZpJGNEv4QqdE10o3DDWgwwGah20IeCyTawt9vOwHS8tIfXIcQ6kvi/sMsc9pyWCN8sQUpeK0tpTW/2INQ/Absd9nVOCx2EPjdAYapYLC0ZVANscMzrfmZHu4DGno7h+4mPB26l1lzSOel6hK7trPyQuxEqDYxg0qLinY2mUtS687Z8t+jL7M2cWF3geMLnl3mE6qm5yGnj1T1aIseFRGdIoF2FH5bKDlmy7Bm8EHLUlsviVzbEUkC/a3OjdepQuYqHG5h9rQ1V5lecZunSUmChYSkSN9qcPp8qaO75I+cl4vThH9bI46cXgitEEVi1w3k36dYKhJGbRNOQel1DHkpOKNvHiQ3VfNYvADnDzWUK5qKjYCtjOc7y6TQEqkyfZgnco+LpCvwFwG5yZiu8kw== openpgp:0x0CDEABD7"];

    };

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # Enable the OpenSSH daemon.
    services.openssh.enable = true;
    services.openssh.extraConfig = "AllowAgentForwarding yes";

    # Set up networking and secure it
    networking = {
        networkmanager.enable = true;
        firewall = {
            enable = true;
            allowedTCPPorts = [ 443 80 ];
            #allowedUDPPorts = [ ... ];
            allowPing = false;
        };
    };

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

    # Set environment variables
    environment.variables = {
        NIXOS_CONFIG = "$HOME/.config/nixos/configuration.nix";
        NIXOS_CONFIG_DIR = "$HOME/.config/nixos/";
    };

    # Sound
    sound = {
        enable = true;
        mediaKeys.enable = true;
    };

    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;

    services.pipewire = {
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    
    # Disable bluetooth, enable pulseaudio, enable opengl (for Wayland)
    hardware = {
        bluetooth.enable = false;
        opengl = {
            enable = true;
            driSupport = true;
        };
    };

    # Do not touch
    system.stateVersion = "20.09";
}
