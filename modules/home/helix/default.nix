{
  programs.helix = {
    enable = true;
    defaultEditor = true;
    settings = {
      theme = "term16_dark";
      editor = {
        lsp.display-messages = true;
        lsp.display-inlay-hints = true;
        file-picker = {
          hidden = false;  # ignore hidden files
          follow-symlinks = true;
          git-ignore = true;
          git-global = true;
          ignore = true;
        };
        auto-pairs = false;
      };
    };
    languages = {
      language-server = {
        pylyzer = {
          command = "pylyzer";
          args = ["--server"];
        };
        rust-analyzer = {
          command = "rust-analyzer";
          config = {
            linkedProjects = ["./Cargo.toml"];
          };
        };
        nil = {
          command = "nil";
        };
      };
      language = [
        {
          name = "python";
          language-servers = ["pylyzer"];
          auto-format = true;
        }
        {
          name = "rust";
          language-servers = ["rust-analyzer"];
          auto-format = true;
        }
        {
          name = "nix";
          language-servers = ["nil"];
          auto-format = true;
        }
      ];
    };
  };
}
