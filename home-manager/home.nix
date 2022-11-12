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

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      TERMINAL = "alacritty";
    };

    # add user packages here!
    packages = with pkgs; [
      curl
      gh
      librewolf
      pfetch
      obsidian
      python3
      nheko
      zenith
    ];
  };

  programs = {
    bash = {
      enable = true;

      initExtra = "pfetch";
      shellAliases = {
        nixos-rebuild = "sudo nixos-rebuild";  # I always mess this one up!
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

    # TODO: move to seperate flake!
    neovim = {
      coc.enable = true;
      enable = true;
      viAlias = true;
      vimAlias = true;
      withPython3 = true;
      plugins = with pkgs.vimPlugins; [
        # general
        indentLine  # shows line
        vim-commentary  # `gcc` to comment out/in a line; `gc` for motion/viz
                        # use e.g. `:97,98Commentary` to specify a range
        ale  # async lint engine

        # elm extensions
        elm-vim

        # haskell extensions
        neco-ghc
        vim2hs

        # git extensions
        vim-fugitive
        # vim-gitgutter

        # nix extensions
        vim-nix

        # python extensions
        jedi-vim

        # scala extensons
        vim-scala

        # theme
        molokai
        vim-airline
      ];

      extraConfig = ''
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

      "" always show status bar
      set laststatus=2

      "" center screen on search match
      nnoremap n nnzzzv
      nnoremap N Nzzzv

      let g:indentLine_enabled = 1
      let g:indentLine_faster = 1

      command! FixWhitespace :%s/\s\+$//e

      augroup vimrc-sync-fromstart
        autocmd!
        autocmd BufEnter * :syntax sync maxlines=200
      augroup END

      augroup vimrc-remember-cursor-position
        autocmd!
        autocmd BufReadPost* if line("'\"") > 1 && line("'\"") <=line("$") | exe "normal! g`\"" | endif
      augroup END

      set autoread
      '';
    };

    git = {
      enable= true;
      userName = "data-djinn";
      userEmail = "data-djinn@pm.me";
      diff-so-fancy.enable = true;
    };

    home-manager = {
      enable = true;
      # TODO: fix this path = "$HOME/nix-config/home-manager";
    };

    rbw.enable = true;  # bitwarden cli client TODO: self-host
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

  manual.html.enable = true;  # view with `home-manager-help`

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "22.05";
}
