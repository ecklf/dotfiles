{ config, pkgs, lib, libs, ... }:
{
  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      enableAutosuggestions = true;
      syntaxHighlighting.enable = true;
      zsh-abbr.abbreviations = { };
      # Whether to enable Bash And Zsh shell history suggest box - easily view, navigate, search and manage your command history
      # programs.hstr.enable = true;
      history = {
        # Expire duplicates first
        expireDuplicatesFirst = true;
        # Save timestamp into the history file
        extended = true;
        # If a new command line being added to the history list duplicates an older one, the older command is removed from the list (even if it is not the previous event)
        ignoreAllDups = true;
        # Do not enter command lines into the history list if they are duplicates of the previous event
        ignoreDups = true;
        # Do not enter command lines into the history list if they match any one of the given shell patterns
        ignorePatterns = [ ];
        # Do not enter command lines into the history list if the first character is a space
        ignoreSpace = true;
        # History file location	string
        # programs.zsh.history.path = "${pkgs.home-manager.home}/.zsh_history";
        # Number of history lines to save	
        save = 50000;
        # Number of history lines to keep
        size = 10000;
        # Share command history between zsh sessions
        share = true;
        # historySubstringSearch = {
        #   historySubstringSearch.enable = true;
        #   # The key codes to be used when searching down. The default of ^[[B may correspond to the DOWN key – if not, try $terminfo[kcud1].	(list of string) or string
        #   historySubstringSearch.searchDownKey = [ ];
        #   historySubstringSearch.searchUpKey = true;
        # };
      };
      initExtraFirst = ''
        # Disable macOS Dock bouncing (xterm bellIsUrgent)
        printf "\e[?1042l"
        # Emacs keybindings
        bindkey -e 
        # Map end-of-line key in the same way as zprezto editor module to prevent issue with tmux-resurrect.
        bindkey "^E" end-of-line 
        # Allow pipe to existing file. Prevent issue with history save in tmux-resurrect.
        setopt CLOBBER 
      '';
      initExtraBeforeCompInit = ''
        zstyle ':completion:*' menu select
        zmodload zsh/complist
      '';
      initExtra = ''
        # pnpm
        export PNPM_HOME="/Users/$(whoami)/Library/pnpm"
        export PATH="$PNPM_HOME:$PATH"

        # Adding color support for ls etc.
        precmd () {print -Pn "\e]0;%~\a"}

        # Include hidden files
        _comp_options+=(globdots)
        autoload -Uz url-quote-magic
        zle -N self-insert url-quote-magic
      
        # cheat $1, returns RL examples of provided tool 
        function cheat(){
          command curl "cheat.sh/$1"
        }

        # Copies current branch name to clipboard
        function copy_curr_branch(){
          local ref="$(command git symbolic-ref HEAD 2> /dev/null)"

          if [[ -n "$ref" ]]; then
            echo "''${ref#refs/heads/}" | pbcopy
          fi
        }

        if [[ $(arch) == "arm64" ]]; then
          eval "$(fnm env --arch arm64 --use-on-cd)"
        else
          eval "$(fnm env --use-on-cd)"
        fi
      '';
      # Can be fetched /w nix-prefetch-github zsh-users zsh-autosuggestions
      plugins =
        [
          {
            name = "zsh-autosuggestions";
            src = pkgs.fetchFromGitHub {
              owner = "zsh-users";
              repo = "zsh-autosuggestions";
              rev = "c3d4e576c9c86eac62884bd47c01f6faed043fc5";
              hash = "sha256-B+Kz3B7d97CM/3ztpQyVkE6EfMipVF8Y4HJNfSRXHtU=";
            };
          }
          {
            name = "zsh-completions";
            src = pkgs.fetchFromGitHub {
              owner = "zsh-users";
              repo = "zsh-completions";
              rev = "9e341f6a202e83e2dc0a587f4970fa375de84d4e";
              sha256 = "sha256-HVuCHOCP2zeUY59JYhzQi6tHYBDUwNeY5fm8pALVxpc=";
            };
          }
          {
            name = "aws";
            file = "aws.plugin.zsh";
            src = pkgs.fetchFromGitHub {
              owner = "ohmyzsh";
              repo = "ohmyzsh";
              rev = "5ea2c68be88452b33b35ba8004fc9094618bcd87";
              hash = "sha256-Mhn66ZYqPL3z+tPcEUnF8ybckxybaV4TxNX+WUeClq4=";
            } + "/plugins/aws";
          }
          {
            name = "enhancd";
            file = "init.sh";
            src = pkgs.fetchFromGitHub {
              owner = "babarot";
              repo = "enhancd";
              rev = "230695f8da8463b18121f58d748851a67be19a00";
              sha256 = "sha256-XJl0XVtfi/NTysRMWant84uh8+zShTRwd7t2cxUk+qU=";
            };
          }
        ];
    };
  };
}
