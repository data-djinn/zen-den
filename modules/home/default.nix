{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
let
  primary_user = "djinn"; # TODO: make dynamic
in {
  imports = [
    ./firefox
    ./helix
    ./themes
  ];

  home = {
    username = "${primary_user}";
    homeDirectory = "/home/${primary_user}";

    keyboard = {
      layout = "us";
      variant = "dvorak";
      options = [
        "caps: swapescape" # use caps lock as escape key
        "ctrl: swap_ralt_rctl"
      ];
    };

    sessionVariables = {
      EDITOR = "hx";
      VISUAL = "hx";
      TERMINAL = "alacritty";
      GPG_TTY = "$(tty)";
    };

    # add user packages here!
    packages = with pkgs; let
      global-python-packages = python-packages:
        with python-packages; [
          pip
          more-itertools
          httpx # requests with async support
        ];
      python-with-global-packages = python3.withPackages global-python-packages;
    in [
      pre-commit

      # language servers & linters
      pylyzer
      ruff
      rust-analyzer
      nil
      alejandra
      gopls
      gofumpt
      go

      brightnessctl
      curl
      gh
      gnupg
      jq
      fastfetch
      protonvpn-cli
      python-with-global-packages
      ripgrep
      zellij

      hyprpaper
      waybar
      wofi
    ];
  };

  fonts.fontconfig.enable = true; # access fonts in home.packages

  programs = {
    bash = {
      enable = true;

      initExtra = ''
        fastfetch
        export PS1="\n\[$(tput setaf 2)\]\t [\[$(tput setaf 34)\]\u@\[$(tput setaf 40)\]\H: \[$(tput setaf 220)\]\w\[$(tput setaf 2)\]]\[$(tput setaf 88)\]\$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/')\[$(tput setaf 2)\]\$ \[$(tput sgr0)\]"
      ''; # bash prompt: HH:MM:SS [usr@host.fullname: /curr/dir/] (git branch)

      historyIgnore = ["ls" "ll" "cd" "exit"];
      historyControl = ["erasedups"];

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
        font.size = 10.0;
        window.opacity = 0.7;
        selection.save_to_clipboard = true;
        general.live_config_reload = true;
        general.import = ["~/.config/alacritty/colors.toml"];
      };
    };

    git = {
      enable = true;
      userName = "data-djinn";
      userEmail = "data-djinn@pm.me";
      signing = {
        signByDefault = true;
        key = "A974448D85A49F02";
      };
      diff-so-fancy.enable = true;
      aliases = {
        a = "add";
        c = "commit -Sm";
        ca = "commit -S --amend";
        can = "commit -S --amend --no-edit";
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

      extraConfig = {
        merge = {
          tool = "vimdiff";
          conflictstyle = "diff3";
        };
        pull = {
          rebase = true;
        };
      };
    };

    gpg = {
      enable = true;
      settings = {
        # copied from dr duh
        personal-cipher-preferences = "AES256 AES192 AES";
        personal-digest-preferences = "SHA512 SHA384 SHA256";
        personal-compress-preferences = "ZLIB BZIP2 ZIP Uncompressed";
        default-preference-list = "SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed";
        cert-digest-algo = "SHA512";
        s2k-digest-algo = "SHA512";
        s2k-cipher-algo = "AES256";
        charset = "utf-8";
        fixed-list-mode = true; # show unix timestamps
        no-comments = true;
        no-emit-version = true;
        no-greeting = true;
        keyid-format = "0xlong"; # long hexadecimal key format
        list-options = "show-uid-validity";
        verify-options = "show-uid-validity";
        with-fingerprint = true;
        require-cross-certification = true;
        no-symkey-cache = true;
        use-agent = true; # enable smartcard
        throw-keyids = true;
      };
    };

    home-manager = {
      enable = true;
      # TODO: fix this path = "$HOME/zen-den/home-manager";
    };

    rbw = with pkgs; {
      enable = true; # bitwarden cli client
      settings = {
        email = "data-djinn@pm.me";
        # identity_url = "?"; TODO: self-host
        lock_timeout = 300;
        pinentry = pkgs.pinentry-curses;
      };
    };
  };

  services.gpg-agent = with pkgs; {
    enable = true;
    enableSshSupport = true;
    pinentryPackage = pkgs.pinentry-curses;
  };

  # ===== Sway (Wayland Tiling Window Manager) =====
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      input = {
        kb_layout = "us";
        kb_variant = "dvorak";
      };
      "$terminal" = "alacritty";
      "$mod" = "SUPER";
      "$launcher" = "wofi --show drun";
      bind =
        [
          "$mod, Return, exec, $terminal"
          "$mod, Space, exec, $launcher"
          "$mod, Q, killactive"
          "$mod, H, movefocus, l"
          "$mod, J, movefocus, d"
          "$mod, K, movefocus, u"
          "$mod, L, movefocus, r"
          #"$mod SHIFT, R, reload"
        ]
        ++ (
          builtins.concatLists (builtins.genList (
              i: let
                ws = i + 1;
              in [
                "$mod, code:1${toString i}, workspace, ${toString ws}"
                "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
              ]
            )
            9)
        );

      exec-once = ["hyprpaper" "waybar"];
    };
  };

  programs.waybar.enable = true;
  programs.wofi.enable = true;

  services.wlsunset = {
    enable = true;
    latitude = "40.7";
    longitude = "-73.9";
    gamma = ".4";
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.11";
}
