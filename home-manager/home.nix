# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)

{ inputs, lib, config, pkgs, ... }: {
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors), use something like:
    # inputs.nix-colors.homeManagerModule

    # Feel free to split up your configuration and import pieces of it here.
  ];

  home = {
    username = "djinn";
    homeDirectory = "/home/djinn";

    keyboard = {
      layout = "us";
      variant = "dvorak";
      options = [ "caps: swapescape" ];  # use caps lock as escape key
    };

    # add user packages here!
    packages = with pkgs; [
      curl
      gh
      librewolf
      pfetch
      obsidian
      python3
      zenith
    ];
  };

  programs = {
    bash = {
      enable = true;

      initExtra = "pfetch";
      shellAliases = {
        ls = "ls --color=auto";
        ll = "ls -lA";
        lm = "ls -t -1";
        lt = "ls --human-readable --size -1 -S --classify";
        ".." = "cd ..";
        "..." = "cd ../..";
        count = "find . -type f | wc -l";
        cpv = "rsync -ah --info=progress2";
        gs = "git fetch && git status";
        ga = "git fetch && git add";
        gc = "git commit -m";
      };
    };

    alacritty = {
      enable = true;
      settings = {
        size = 8.0;
      };
    };

    # TODO: move to seperate flake!
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      withPython3 = true;
      plugins = with pkgs.vimPlugins; [
        vim-nix
        jedi-vim
        vim-airline
        vim-airline-themes
        molokai
        vim-commentary
        indentLine
      ];
      extraConfig = "
      set fileencoding=utf-8

      set backspace=indent,eol,start

      set tabstop=4
      set softtabstop=0
      set shiftwidth=4
      set expandtab

      set hlsearch
      set incsearch
      set ignorecase
      set smartcase

      syntax on
      set ruler
      set number

      colorscheme molokai

      set wildmenu

      let g:indentLine_enabled = 1
      let g:indendLink_concealcursor = ''
      let g:indentLine_faster = 1
      ";
    };

    git = {
      enable= true;
      userName = "data-djinn";
      userEmail = "data-djinn@pm.me";
      diff-so-fancy.enable = true;
    };

    home-manager = {
      enable = true;
      path = "$HOME/nix-config/home-manager";
    };

    rbw.enable = true;  # bitwarden cli client TODO: self-host
  };

    # reduce blue light after sunset
    services.redshift = {
      enable = true;
      provider = "geoclue2";
    };
  
  manual.html.enable = true;  # view with `home-manager-help`

  # Nicely reload system units when changing configs
  systemd.user = {
    startServices = "sd-switch";
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      TERMINAL = "alacritty";
    };
  };
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "22.05";
}
