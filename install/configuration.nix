{ config, pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration-zfs.nix ./zfs.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  time.timeZone = "Europe/Paris";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true; # use xkbOptions in tty.
  };

  services.xserver.enable = true;

  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  

  services.xserver.layout = "fr";
  services.xserver.xkbOptions = "eurosign:e, caps:escape";

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  services.xserver.libinput.enable = true;

  users.users.anael= {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    initialHashedPassword = "$6$T1cnJ4uZ1Jtw47QD$2bIoI/5t9qk6LUJTGI1NqG/auTKhXjNof3wjbzQv3uI7bMlJv5V2StQ1trSLZPXm/Wasqo5JsvOCk2724igL90";
    packages = with pkgs; [
      firefox
      thunderbird
    ];
  };

  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    neovim
    git
  ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  system.copySystemConfiguration = true;

  system.stateVersion = "22.05"; # Did you read the comment?

}

