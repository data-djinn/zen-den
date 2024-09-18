{ inputs, lib, config, pkgs, ... }:
  # This is your home-manager configuration file
  # Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
let
  primary_user = "djinn";  # TODO: make dynamic
in
{
  imports = [
    ./firefox
    ./neovim
  ];

  home = {
    username = "${primary_user}";
    homeDirectory = "/home/${primary_user}";

    keyboard = {
      layout = "us";
      variant = "dvorak";
      options = [
        "caps: swapescape"  # use caps lock as escape key
        "ctrl: swap_ralt_rctl"
      ];
    };

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      TERMINAL = "alacritty";
    };

    # add user packages here!
    packages = with pkgs;
      let
        python-linters = python-packages: with python-packages; [
          flake8
          flake8-bugbear
          bandit
          black
        ];
        python-with-linters = python3.withPackages python-linters;
      in
      [
        brightnessctl
        curl
        gh
        jq
        obsidian # TODO: add overlay to include plugins & vault already connected
        pfetch
        protonvpn-cli
        python-with-linters
        ripgrep
        zenith
      ];
  };

  fonts.fontconfig.enable = true;  # access fonts in home.packages

  programs = {
    bash = {
      enable = true;

      initExtra = ''
        pfetch
        export PS1="\n\[$(tput setaf 2)\]\t [\[$(tput setaf 34)\]\u@\[$(tput setaf 40)\]\H: \[$(tput setaf 220)\]\w\[$(tput setaf 2)\]]\[$(tput setaf 88)\]\$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/')\[$(tput setaf 2)\]\$ \[$(tput sgr0)\]"
      ''; # bash prompt: HH:MM:SS [usr@host.fullname: /curr/dir/] (git branch)

      historyIgnore = [ "ls" "ll" "cd" "exit" ];
      historyFile = "/persist/.bash_history";
      historyControl = [ "erasedups" ];

      shellAliases = {
        nixos-rebuild = "sudo nixos-rebuild"; # I always mess this one up!
        ls = "ls --color=auto";
        ll = "ls -lA";
        lm = "ls -lt -1";
        lt = "ls --human-readable --size -1 -Sl--classify";
        ".." = "cd ..";
        "..." = "cd ../..";
        count = "find . -type f | wc -l";
        cpv = "rsync -ah --info=progress2";
      };
    };

    alacritty = {
      enable = true;
      settings = {
        font = {
          size = 8.0;
        };
      };
    };

    git = {
      enable = true;
      userName = "data-djinn";
      userEmail = "data-djinn@pm.me";
      diff-so-fancy.enable = true;
      aliases = {
        a = "add";
        c = "commit -m";
        ca = "commit --amend";
        can = "commit --amend --no-edit";
        co = "checkout";
        d = "diff";
        f = "fetch";
        fo = "fetch origin";
        fu = "fetch upstream";
        lg = "log --graph --decorate --abbrev-commit";
        lga = "log --graph --decorate --abbrev-commit --all";
        r = "remote";
        ra = "remode add";
        rr = "remote rm";
        rv = "remote -v";
        s = "status";
      };

      extraConfig  = {
        merge = {
          tool = "vimdiff";
          conflictstyle = "diff3";
        };
        pull = {
          rebase = true;
        };
        gpg.format = "ssh";
        user.signingkey = "$/home/{primary_user}/.ssh/id_ed255519.pub";
      };
    };

    home-manager = {
      enable = true;
      # TODO: fix this path = "$HOME/zen-den/home-manager";
    };

    rbw = {
      enable = true; # bitwarden cli client
      settings = {
        email = "data-djinn@pm.me";
        # identity_url = "?"; TODO: self-host
        lock_timeout = 300;
      };
    };
  };

  # ===== Sway (Wayland Tiling Window Manager) =====
  wayland.windowManager.sway = {
    enable = true;
    config = {
      input = {
        "*" = {  # TODO: bash script to find current keyboard identifier
          xkb_layout = "us";
          xkb_variant = "dvorak";
          xkb_options = "caps:swapescape,ctrl:swap_lalt_lctl,ctrl:swap_ralt_rctl";
        };
      };
      terminal = "alacritty";
    };
  };

  services.wlsunset = {
    enable = true;
    latitude = "40.7";
    longitude = "-73.9";
    gamma = ".4";
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
