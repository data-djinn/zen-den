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
      enable = true;
      withPython3 = true;
      coc = {
        enable = true;
        settings = {
          "suggest.noselect" = true;
          "suggest.enablePreview" = true;
          "suggest.enablePreselect" = true;
          "suggest.disableKind" = true;
          languageserver = {
            haskell = {
              command = "haskell-language-server-wrapper";
              args = [ "--lsp"  ];
              rootPatterns = [
                "*.cabal"
                "stack.yaml"
                "cabal.project"
                "package.yaml"
                "hie.yaml"
              ];
              filetypes = [ "haskell" "lhaskell" ];
            };
            nix = {
              command = "rnix-lsp";
              filetypes = ["nix"];
            };
          };
        };
      };

      viAlias = true;
      vimAlias = true;
      plugins = with pkgs.vimPlugins; [
        # general
        indentLine  # shows line
        vim-commentary  # `gcc` to comment out/in a line; `gc` for motion/viz
                        # use e.g. `:97,98Commentary` to specify a range
        ale  # async lint engine
        coc-nvim
        coc-python

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

      extraConfig = builtins.readFile ./init.vim;

      extraPackages = with pkgs; [
        (python3.withPackages (ps: with ps; [
          black
          flake8
        ]))
        nodejs  # required for coc
        haskell-language-server
        rnix-lsp
      ];
      extraPython3Packages = (ps: with ps; [
        jedi
      ]);
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
  xdg.configFile."nvim/coc-settings.json".text = builtins.readFile ./coc-settings.json;

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
