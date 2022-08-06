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
  environment.etc."shadow".source
    = "/persist/etc/shadow";
users.users.root.initialHashedPassword = "$6$32v1l1wPEx3D3Tna$2aEqz7c42DZEwfmuZanIJAYWJO/39fvdPnaxM3QECsLddArN4bm8xYFf6DwjDJKpMTlrddbRutbWD08x.6mFj.";
}
