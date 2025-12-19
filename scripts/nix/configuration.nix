# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
  ];

  programs.nix-ld.enable = true;
  environment.systemPackages = with pkgs; [
    wget
    git
    direnv

    # Customization for Zsh
    fzf
    chroma
    starship
  ];

  environment.etc = {

  };

  users.users."nixos".shell = pkgs.zsh;

  programs.zsh = {
    autosuggestions = {
      enable = true;
      async = true;
    };

    enable = true;
    enableBashCompletion = true;
    enableCompletion = true;
    enableGlobalCompInit = true;
    enableLsColors = true;

    histSize = 10000;
    histFile = "$HOME/.zsh_history";

    loginShellInit = ''
      export ZSH_CUSTOM=/etc/zsh/custom
    '';

    ohMyZsh = {
      enable = true;
      custom = "/etc/zsh/custom";
      cacheDir = "$HOME/.config/zsh/cache";
      plugins = [
        "aliases"
        "branch"
        "colorize"
        "command-not-found"
        "direnv"
        "docker"
        "gh"
        "gitfast"
        "pip"
        "python"
        "rust"
        "zsh-interactive-cd"
      ];
    };

    shellInit = ''
      export ZSH_COLORIZE_TOOL=chroma

      autoload -Uz compinit && compinit
      eval "$(starship init zsh)"
      eval "$(starship completions zsh)"
    '';

    shellAliases = {
      update-system = "sudo nixos-rebuild switch --flake git+https://github.com/nauxi-xl/Aletix#nixos";
      change-theme = "starship preset -o $HOME/.config/starship.toml";
    };

    syntaxHighlighting = {
      enable = true;
      highlighters = [
        "main"
        "brackets"
        "pattern"
        "regexp"
        "cursor"
        "line"
      ];
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
