{ pkgs, lib, config, ... }:
with lib;
let cfg = config.modules.zsh;
in {
    options.modules.zsh = { enable = mkEnableOption "zsh"; };

    config = mkIf cfg.enable {
    	home.packages = [
	    pkgs.zsh
	];

        programs.zsh = {
            enable = true;

            # directory to put config files in
            dotDir = ".config/zsh";

            enableCompletion = true;
            enableAutosuggestions = false;
            enableSyntaxHighlighting = true;

            # .zshrc
            initExtra = ''
                PROMPT="%F{blue}%m %~%b %(?.%F{green}%Bλ%b |.%F{red}?) %f"

                bindkey '^ ' autosuggest-accept

                edir() { tar -cz $1 | age -p > $1.tar.gz.age && rm -rf $1 &>/dev/null && echo "$1 encrypted" }
                ddir() { age -d $1 | tar -xz && rm -rf $1 &>/dev/null && echo "$1 decrypted" }
                autoload -U up-line-or-beginning-search
                autoload -U down-line-or-beginning-search
                zle -N up-line-or-beginning-search
                zle -N down-line-or-beginning-search
                bindkey "^[[A" up-line-or-beginning-search
                bindkey "^[OA" up-line-or-beginning-search
                bindkey "^[[B" down-line-or-beginning-search
                bindkey "^[OB" up-line-or-beginning-search
            '';

            # basically aliases for directories: 
            # `cd ~dots` will cd into ~/.config/nixos
            dirHashes = {
                dots = "$HOME/.config/nixos";
                stuff = "$HOME/stuff";
                media = "/run/media/$USER";
                junk = "$HOME/stuff/other";
            };

            # Tweak settings for history
            history = {
                save = 1000;
                size = 1000;
                path = "$HOME/.cache/zsh_history";
            };

            # Set some aliases
            shellAliases = {
                c = "clear";
                mkdir = "mkdir -vp";
                rm = "rm -rifv";
                mv = "mv -iv";
                cp = "cp -riv";
                cat = "bat --paging=never --style=plain";
                ls = "exa --icons";
                tree = "exa --tree --icons";
                rebuild = "sudo nixos-rebuild switch --flake $NIXOS_CONFIG_DIR --fast; notify-send 'Rebuild complete\!'";
            };

            # Source all plugins, nix-style
            plugins = [
            {
                name = "auto-ls";
                src = pkgs.fetchFromGitHub {
                    owner = "notusknot";
                    repo = "auto-ls";
                    rev = "62a176120b9deb81a8efec992d8d6ed99c2bd1a1";
                    sha256 = "08wgs3sj7hy30x03m8j6lxns8r2kpjahb9wr0s0zyzrmr4xwccj0";
                };
            }
        ];
    };
};
}
