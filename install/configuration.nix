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
    openssh.authorizedKeys.keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDaxmFvnF9smiZnDySxS5Coo4dMiUQ7nOIKx3Fk1jEMFZNpntKCV7MFdRDS3goc0Cx0GOHMhqgTOJKKb9CW1tzmPStSiz/72YeOpEC/tXnROFc4k+fc4cwZWEdr+eLIes3LCBuo1N/jtDVAApdgEuL6xNLqc2PqQG7MYIioz1kENpre5dGE9U4Bm7HsOQkaHzBmIBbdgyTq4vz5TvB5aYdI3qzzNMRuDaBpqU/eT08+R8zPAhjvYnpuq9y2kJf5YNU3mIUqnPjB1ivopZqLmLpz6/ZpJGNEv4QqdE10o3DDWgwwGah20IeCyTawt9vOwHS8tIfXIcQ6kvi/sMsc9pyWCN8sQUpeK0tpTW/2INQ/Absd9nVOCx2EPjdAYapYLC0ZVANscMzrfmZHu4DGno7h+4mPB26l1lzSOel6hK7trPyQuxEqDYxg0qLinY2mUtS687Z8t+jL7M2cWF3geMLnl3mE6qm5yGnj1T1aIseFRGdIoF2FH5bKDlmy7Bm8EHLUlsviVzbEUkC/a3OjdepQuYqHG5h9rQ1V5lecZunSUmChYSkSN9qcPp8qaO75I+cl4vThH9bI46cXgitEEVi1w3k36dYKhJGbRNOQel1DHkpOKNvHiQ3VfNYvADnDzWUK5qKjYCtjOc7y6TQEqkyfZgnco+LpCvwFwG5yZiu8kw== openpgp:0x0CDEABD7"];
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

  nix = {
    package = pkgs.nixFlakes; # or versioned attributes like nixVersions.nix_2_8
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
   };

    programs.git = {
        enable = true;
        config = {
          user = { 
            name = "anael";
            email = "anaellatassa@gmail.com";
          };
        };
   };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  system.copySystemConfiguration = true;

  system.stateVersion = "22.05"; # Did you read the comment?

}

