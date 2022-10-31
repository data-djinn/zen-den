# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)

{ inputs, lib, config, pkgs, ... }: {
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors), use something like:
    # inputs.nix-colors.homeManagerModule

    # Feel free to split up your configuration and import pieces of it here.
  ];

  xsession.enable = true;
  home = {
    username = "djinn";
    homeDirectory = "/home/djinn";
    
    sessionVariables = {  # env vars to always set at login
      EDITOR = "nvim";
      TERM = "kitty";
    };

    keyboard = {
      layout = "us";
      variant = "dvorak";
      options = [ "caps: swapescape" ];  # use caps lock as escape key
    };

    # add user packages here!
    packages = with pkgs; [
      curl
      gh
      kitty
      librewolf
      redshift
      pfetch
      python3
      zenith
    ];
  };

  # Add stuff for your user as you see fit:
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
      };
    };

    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
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
  
  manual.html.enable = true;  # view with `home-manager-help`

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "22.05";
}
