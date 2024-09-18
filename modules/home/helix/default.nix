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
          hidden = false; # ignore hidden files
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
        ruff = {
          command = "ruff";
          args = ["server" "-q" "--preview"];
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
          language-servers = ["pylyzer" "ruff"];
          formatter = {
            command = "ruff";
            args = ["format" "-"];
          };
          auto-format = true;
        }
        {
          name = "rust";
          language-servers = ["rust-analyzer"];
          formatter = {command = "cargo fmt";}; # depends on rust toolchain in nix shell
          auto-format = true;
        }
        {
          name = "nix";
          language-servers = ["nil"];
          formatter = {command = "alejandra";};
          auto-format = true;
        }
      ];
    };
  };
}
