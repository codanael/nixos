{ config, pkgs, ... }:

{ boot.supportedFilesystems = [ "zfs" ];
  networking.hostId = "60097d8b";
  services.openssh = {
    enable = true;
    hostKeys = [
      {
        path = "/persist/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
      {
        path = "/persist/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
        bits = 4096;
      }
    ];
  };
  systemd.tmpfiles.rules = [
    "L /var/lib/bluetooth - - - - /persist/var/lib/bluetooth"
  ];
  environment.etc."NetworkManager/system-connections" = {
    source = "/persist/etc/NetworkManager/system-connections/";
  };
  environment.etc."machine-id".source
    = "/persist/etc/machine-id";
users.users.root.initialHashedPassword = "$6$Gaj6FZyEFgmKXza2$xBB1meV9wzjFLYTzH31X9i56R4RfxBVEdLEtedVK.GGZM5aFXms/jqN1FUF7czCvce1PVoiZyLYY66.Z9hLAi1";
}
