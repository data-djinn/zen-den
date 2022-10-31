# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)

{ inputs, lib, config, pkgs, ... }: {
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors), use something like:
    # inputs.nix-colors.homeManagerModule

    # Feel free to split up your configuration and import pieces of it here.
  ];

  # TODO: Set your username
  home = {
    username = "djinn";
    homeDirectory = "/home/djinn";
  };

  # Add stuff for your user as you see fit:
  programs = {
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
    };

    git = {
      enable= true;
      userName = "data-djinn";
      userEmail = "data-djinn@pm.me";
    };

    home-manager.enable = true;
  };
  
  # add user packages here!
  home.packages = with pkgs; [ 
    alacritty
    curl
    gh
    librewolf
    python3
    zenith
  ];

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "22.05";
}
