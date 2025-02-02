{ pkgs
, ...
}:
let
  inherit (pkgs.lib.lists) subtractLists;
in
{
  system = {
    defaults = {
      NSGlobalDomain = {
        AppleKeyboardUIMode = 3;
        ApplePressAndHoldEnabled = false;
        InitialKeyRepeat = 10;
        KeyRepeat = 1;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
        _HIHideMenuBar = false;
      };

      screencapture = { location = "/tmp"; };
      dock = {
        autohide = true;
        mru-spaces = false;
        orientation = "left";
        showhidden = true;
      };

      finder = {
        AppleShowAllExtensions = true;
        QuitMenuItem = true;
        FXEnableExtensionChangeWarning = false;
      };

      trackpad = {
        Clicking = true;
        TrackpadThreeFingerDrag = true;
      };
    };

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
  };

  programs.bash.enable = true;

  homebrew =
    let
      casks = rec {
        fonts = [
          "font-caskaydia-cove-nerd-font"
          "font-fira-code-nerd-font"
          "font-hasklug-nerd-font"
        ];
        fun = [
          "spotify"
          "steam"
        ];
        work = [
          "1password"
          "dropbox"
          "robo-3t"
          "slack"
          "xca"
        ];
        comms = [
          "discord"
        ];
        util = [
          "alfred"
          "docker"
          "insomnia"
          "karabiner-elements"
          "keybase"
          "macfuse"
          "notion"
          "parsec"
          "qlvideo"
          "raycast"
          "rectangle"
          "utm"
        ];
        all = fonts ++ fun ++ work ++ comms ++ util;
        all_personal = subtractLists work all;
        all_work = subtractLists fun all;
      };
    in
    {
      enable = true;
      taps = [
        "homebrew/cask"
        "homebrew/cask-drivers"
        "homebrew/cask-fonts"
        "homebrew/cask-versions"
        "homebrew/core"
        "homebrew/services"
      ];
      brews = [
        "readline"
        "sshfs"
        "qemu"
      ];
      onActivation = {
        autoUpdate = true;
        cleanup = "zap";
        upgrade = true;
      };
      casks = casks.all_personal;
      masApps = {
        Wireguard = 1451685025;
        Poolside = 1514817810;
      };
      extraConfig = "";
    };
}
