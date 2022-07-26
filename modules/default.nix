{ inputs, pkgs, config, ... }:

{
    home.stateVersion = "21.03";
    imports = [
        # gui
        ./firefox

        # cli
        ./nvim
        ./zsh
        ./git
        ./gpg

        # system
	    ./packages
    ];
}
