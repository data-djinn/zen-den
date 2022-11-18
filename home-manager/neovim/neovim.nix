{pkgs, inputs, system, ... }:
{
  programs.neovim = {
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

  xdg.configFile."nvim/coc-settings.json".text = builtins.readFile ./coc-settings.json;
}
