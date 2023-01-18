{ inputs, lib, config, pkgs, ... }:
  # This is your home-manager configuration file
  # Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
let
  primary_user = "djinn";  # TODO: make dynamic
in
{
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors), use something like:
    # inputs.nix-colors.homeManagerModule
    ./neovim/neovim.nix
  ];

  home = {
    username = "${primary_user}";
    homeDirectory = "/home/${primary_user}";

    keyboard = {
      layout = "us";
      variant = "dvorak";
      options = [ "caps: swapescape" ]; # use caps lock as escape key
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
        curl
        gh
        librewolf
        obsidian # TODO: add overlay to include plugins & vault already connected
        pfetch
        protonvpn-cli
        python-with-linters
        ripgrep
        zenith
      ];
  };

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
        gs = "git fetch && git status";
        ga = "git fetch && git add";
        gc = "git commit -m";
        gd = "git diff";
      };
    };

    alacritty = {
      enable = true;
      settings = {
        font.size = 6.0;
      };
    };

    git = {
      enable = true;
      userName = "data-djinn";
      userEmail = "data-djinn@pm.me";
      diff-so-fancy.enable = true;
    };

    home-manager = {
      enable = true;
      # TODO: fix this path = "$HOME/nix-config/home-manager";
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

  # reduce blue light after sunset
  services.redshift = {
    enable = true;
    provider = "geoclue2";
    temperature.day = 6500;
    temperature.night = 3000;
    settings = {
      redshift = {
        brightness-night = 0.4;
      };
    };
  };

    xsession.initExtra = ''
      ln -sf /home/${primary_user}/nix-config/modules/home/nix_flakes_background.jpeg /home/${primary_user}/.background-image
    '';

  manual.html.enable = true; # view with `home-manager-help`

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "22.05";
}
