{ config, lib, inputs, ...}:

{
    imports = [ ../../modules/default.nix ];
    config.modules = {
        # gui
        firefox.enable = true;

        # cli
        nvim.enable = true;
        zsh.enable = true;
        git.enable = true;
        gpg.enable = true;

        packages.enable = true;
    };
}
