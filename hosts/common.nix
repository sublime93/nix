{ pkgs
, flake
, machine-name
, isBarebones ? false
, ...
}:
let
  inherit (flake.inputs) home-manager nix-darwin;

  mms = import
    (fetchTarball {
      url = "https://github.com/mkaito/nixos-modded-minecraft-servers/archive/68f2066499c035fd81c9dacfea2f512d6b0b62e5.tar.gz";
      sha256 = "1nmw497ahb9hjjh0kwr1z782q41gcw5kw4dl4alg8pnyhgq141r1";
    });

  jacobi = import ../home.nix {
    inherit home-manager flake machine-name pkgs isBarebones;
  };
in
rec {
  inherit home-manager jacobi nix-darwin mms pkgs;

  nix = {
    extraOptions = ''
      max-jobs = auto
      narinfo-cache-negative-ttl = 10
      extra-experimental-features = nix-command flakes
      extra-substituters = https://jacobi.cachix.org
      extra-trusted-public-keys = jacobi.cachix.org-1:JJghCz+ZD2hc9BHO94myjCzf4wS3DeBLKHOz3jCukMU=
    '';
    settings = {
      trusted-users = [ "root" "jacobi" ];
    };
  };

  extraGroups = [ "wheel" "networkmanager" "docker" "podman" ];

  sysctl_opts = {
    "fs.inotify.max_user_watches" = 1048576;
    "fs.inotify.max_queued_events" = 1048576;
    "fs.inotify.max_user_instances" = 1048576;
    "net.core.rmem_max" = 2500000;
  };

  defaultLocale = "en_US.UTF-8";
  extraLocaleSettings = let utf8 = "en_US.UTF-8"; in
    {
      LC_ADDRESS = utf8;
      LC_IDENTIFICATION = utf8;
      LC_MEASUREMENT = utf8;
      LC_MONETARY = utf8;
      LC_NAME = utf8;
      LC_NUMERIC = utf8;
      LC_PAPER = utf8;
      LC_TELEPHONE = utf8;
      LC_TIME = utf8;
    };

  env = { };

  name = rec {
    first = "jacobi";
    last = "petrucciani";
    full = "${first} ${last}";
  };

  emails = {
    personal = "j@cobi.dev";
    work = "jacobi.petrucciani@medable.com";
  };

  pubkeys = rec {
    # physical
    galaxyboss = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO9u9+khlywG0vSsrTsdjZEhKlKBpXx8RnwESGw+zIKI galaxyboss";
    megaboss = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEhhl/jKYcglH7+tTYgsVRKqVuf7hwF6yOgpdYIQWAyJ jacobi-megaboss";

    # servers
    bedrock = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHyGIL87ScZN4Bir5yxlLendu4Iex2RjrmDRLE3+u7Aq jacobi@bedrock";
    granite = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN+Ueb5yUyGWNA71L2If6pwy5AORXO3LN4CzREgwWhO2 jacobi@granite";
    titan = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDKnCuUSP/RbAfUvNkD43wm6w5dhsfdIgSqawj9Z0UQX jacobi@titan";
    jupiter = "";
    saturn = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPY2sNJE5ysSTeFzTv2U+zIeIB5LMhbUaP+yC5VDgEHD jacobi@saturn";
    neptune = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPqXt2116T/hpMpdmlh3QquPcF/COXPtJS4BkjwECf++ jacobi@neptune";
    charon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIQf/+Cw19PwfLGRs7VyJR9rqwglDG/ZwBbwJY1Aagxo jacobi@charon";
    mars = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBMW7fOdfDeI+9TwYHPUzApYDlNFOfLkl9NC06Du23mP jacobi@mars";
    phobos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID7CSn6s/Wuxa2sC4NXCIXGvX3oz8BN1vsyaZGd3wJED jacobi@phobos";
    luna = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINOoY9vE2hPcBtoI/sE9pmk4ocO+QWZv2lvtxcPs9oha jacobi@luna";
    milkyway = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII2VPpmvMVt+5LHJfgmsTSdWy5SIM2gBvgpyuT3iMt1a jacobi@milkyway";
    terra = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFWWDYzXHtB3hd/5sWeg+kz+COGxCEWalspwCNnZNOZz jacobi@terra";

    # android
    s21 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICLuqazOtTUHVkywIMHWXizCLmSaEl2C8Oyb9t5LmslD jacobi@s21";
    zfold3 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKuFnEC93wi/fjHE4oAK1A59HkFltRSfHTZelB4AR29u jacobi@zfold3";

    # ios
    ipad = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAQhTANgPfe2Xyw14LjxUyhBmVi/7MJwONf99JvmZrIy jacobi-ipad";
    iphone13 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHyzxXyPhjpAMWSqsJQs/W3IAI+si6y7PUKxckihPynW jacobi@iphone13";

    # laptops
    pluto = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEgmAVUZdA5QrsCQFYhL0bf+NbXowV9M12PPiwoWRMJK jacobi@pluto";
    ymir = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJu8erBI/BUNkvQR4OC+1Q8zrpVzI4NyAufuXieWshQk jacobi@ymir";
    m1max = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJnJ2nh4yutW5Xq11Cp4wdJUU+dJxeNZn9SZsHAj9TRg jacobi@m1max";
    andromeda = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBRLoe5SoO2nipGJw6QLRRLOyfiKtmi2lvnlCQtLz7o4 jacobi@andromeda";
    # nix-daemon on laptops
    nix-m1max = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIwkBMOku4AYYQsWIX1IZdX9azpEgfVXp6uHEYGUbM3K nix@m1max";

    # edge
    edge = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILkME8cVp908fLcQiSYmwSruCBcm4iBR8CS87s8AqNmK jacobi@edge";
    edgewin = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGRFawIUexIkAJ6yovZIJjz/AvWuZLCwTAp4I1Wv5afY jacobi@edgewin";
    hub2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPC6SkLgq4GVlyskAEih+B3aCrIB5PczUOmokdhKSZLC jacobi@hub2";

    # hms deploy
    hms = ''command="bash -lc '/home/jacobi/.nix-profile/bin/hms'" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBJffkD9CKA/sfuBnT4BOb3XZvW0XuLDiyJ+cjdIctq1 jacobi@hms'';

    desktop = [
      galaxyboss
      megaboss
    ];

    server = [
      bedrock
      titan
      saturn
      neptune
      charon
      phobos
      luna
      milkyway
      terra
    ];

    android = [
      s21
      zfold3
    ];

    ios = [
      ipad
      iphone13
    ];

    mobile = android ++ ios;

    laptop = [
      pluto
      m1max
      andromeda
    ];

    usual = [
      galaxyboss
      pluto
      hms
    ] ++ mobile;
    all = desktop ++ server ++ mobile ++ laptop;
  };

  swapDevices = [{ device = "/swapfile"; size = 1024; }];

  security.sudo = {
    extraRules = [
      {
        users = [ "jacobi" ];
        commands = [
          {
            command = "ALL";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
    extraConfig = ''
      Defaults env_keep+=NIX_HOST
      Defaults env_keep+=NIXOS_CONFIG
      Defaults env_keep+=NIXDARWIN_CONFIG
    '';
    wheelNeedsPassword = false;
  };

  _services = {
    blocky = {
      enable = true;
      # settings: https://0xerr0r.github.io/blocky/configuration
      settings = {
        blocking = {
          blackLists = {
            ads = [
              "http://sysctl.org/cameleon/hosts"
              "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
              "https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt"
              "https://s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt"
            ];
            special = [
              "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews/hosts"
            ];
          };
          blockTTL = "1m";
          blockType = "zeroIp";
          clientGroupsBlock = {
            default = [
              "ads"
              "special"
            ];
          };
          downloadAttempts = 5;
          downloadCooldown = "10s";
          downloadTimeout = "4m";
          refreshPeriod = "4h";
          startStrategy = "failOnError";
          whiteLists = {
            ads = [
            ];
          };
        };
        bootstrapDns = "tcp+udp:1.1.1.1";
        caching = {
          cacheTimeNegative = "30m";
          maxItemsCount = 0;
          maxTime = "30m";
          minTime = "5m";
          prefetchExpires = "2h";
          prefetchMaxItemsCount = 0;
          prefetchThreshold = 5;
          prefetching = true;
        };
        clientLookup = {
          clients = {
            luna = [
              "192.168.1.44"
            ];
          };
          singleNameOrder = [
            2
            1
          ];
        };
        conditional = {
          fallbackUpstream = false;
          mapping = { };
          rewrite = { };
        };
        connectIPVersion = "dual";
        customDNS = {
          customTTL = "1h";
          filterUnmappedTypes = true;
          mapping = {
            "cobi" = "192.168.1.44";
            "milkyway.cobi" = "192.168.1.40";
            "titan.cobi" = "192.168.1.41";
            "luna.cobi" = "192.168.1.44";
            "jupiter.cobi" = "192.168.1.69";
            "charon.cobi" = "192.168.1.71";
            "pluto.cobi" = "192.168.1.100";
            "phobos.cobi" = "192.168.1.134";
            "neptune.cobi" = "100.101.139.41";
          };
          rewrite = { };
        };
        ede = {
          enable = true;
        };
        filtering = {
          queryTypes = [
            "AAAA"
          ];
        };
        hostsFile = {
          filePath = "/etc/hosts";
          filterLoopback = true;
          hostsTTL = "60m";
          refreshPeriod = "30m";
        };
        httpPort = 4000;
        logFormat = "text";
        logLevel = "info";
        logPrivacy = false;
        logTimestamp = true;
        minTlsServeVersion = 1.3;
        port = 53;
        prometheus = {
          enable = true;
          path = "/metrics";
        };
        # queryLog = {
        # creationAttempts = 1;
        # creationCooldown = "2s";
        # logRetentionDays = 28;
        # target = "/var/log/blocky/";
        # type = "console";
        # };
        startVerifyUpstream = true;
        upstream = {
          default = [
            "1.1.1.1"
          ];
        };
        upstreamTimeout = "2s";
      };
    };
  };
  services = {
    tailscale.enable = true;
    netdata.enable = true;
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        KexAlgorithms = [
          "curve25519-sha256"
          "curve25519-sha256@libssh.org"
        ];
        Ciphers = [
          "chacha20-poly1305@openssh.com"
          "aes256-gcm@openssh.com"
          # "aes128-gcm@openssh.com"
          "aes256-ctr"
          # "aes192-ctr"
          # "aes128-ctr"
        ];
        Macs = [
          "hmac-sha2-512-etm@openssh.com"
          "hmac-sha2-256-etm@openssh.com"
          "umac-128-etm@openssh.com"
        ];
        X11Forwarding = true;
      };
    };
  };

  mac = {
    apps = {
      Wireguard = 1451685025;
      Poolside = 1514817810;
    };
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
    casks = rec {
      fonts = [
        "font-caskaydia-cove-nerd-font"
        "font-fira-code-nerd-font"
        "font-hasklug-nerd-font"
      ];
      fun = [
        "epic-games"
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
      all_personal = pkgs.lib.lists.subtractLists work all;
      all_work = pkgs.lib.lists.subtractLists fun all;
    };
  };

  timeZone = "America/Indiana/Indianapolis";

  zramSwap = {
    enable = true;
    memoryPercent = 100;
  };

  ports = rec {
    usual = [
      ssh
      http
      https
    ];
    ssh = 22;
    http = 80;
    https = 443;
    nfs = 2049;
    grafana = 3000;
    loki = 3100;
    n8n = 5678;
    jellyfin = 8096;
    home-assistant = 8123;
    prometheus = 9001;
    prometheus_node_exporter = 9002;
    promtail = 9080;
    netdata = 19999;
    plex = 32400;
  };

  minecraft = {
    conf = {
      jre8 = pkgs.temurin-bin-8;
      jre17 = pkgs.temurin-bin-17;
      jre18 = pkgs.temurin-bin-18;
      jre19 = pkgs.temurin-bin-19;

      jvmOpts = builtins.concatStringsSep " " [
        "-XX:+UseG1GC"
        "-XX:+ParallelRefProcEnabled"
        "-XX:MaxGCPauseMillis=200"
        "-XX:+UnlockExperimentalVMOptions"
        "-XX:+DisableExplicitGC"
        "-XX:+AlwaysPreTouch"
        "-XX:G1NewSizePercent=40"
        "-XX:G1MaxNewSizePercent=50"
        "-XX:G1HeapRegionSize=16M"
        "-XX:G1ReservePercent=15"
        "-XX:G1HeapWastePercent=5"
        "-XX:G1MixedGCCountTarget=4"
        "-XX:InitiatingHeapOccupancyPercent=20"
        "-XX:G1MixedGCLiveThresholdPercent=90"
        "-XX:G1RSetUpdatingPauseTimePercent=5"
        "-XX:SurvivorRatio=32"
        "-XX:+PerfDisableSharedMem"
        "-XX:MaxTenuringThreshold=1"
      ];

      defaults = {
        white-list = false;
        spawn-protection = 0;
        max-tick-time = 5 * 60 * 1000;
        allow-flight = true;
      };
    };
  };

  extraHosts = {
    proxmox =
      let
        terra = "192.168.69.10";
        ben = "192.168.69.20";
        bedrock = "192.168.69.70";
      in
      ''
        ${terra} terra
        ${terra} cobi.dev
        ${terra} api.cobi.dev
        ${terra} auth.cobi.dev
        ${terra} vault.cobi.dev
        ${terra} nix.cobi.dev
        ${terra} broadsword.tech
        ${terra} hexa.dev
        ${terra} x.hexa.dev
        ${ben} ben
        ${bedrock} bedrock
      '';
  };

  templates = {
    promtail =
      { hostname
      , loki_ip ? "100.78.40.10"
      , promtail_port ? ports.promtail
      , loki_port ? ports.loki
      , extra_scrape_configs ? [ ]
      }: {
        enable = true;
        configuration = {
          server = {
            http_listen_port = promtail_port;
            grpc_listen_port = 0;
          };
          positions = {
            filename = "/tmp/positions.yaml";
          };
          clients = [{
            url = "http://${loki_ip}:${toString loki_port}/loki/api/v1/push";
          }];
          scrape_configs = [{
            job_name = "journal";
            journal = {
              max_age = "12h";
              labels = {
                job = "systemd-journal";
                host = hostname;
              };
            };
            relabel_configs = [{
              source_labels = [ "__journal__systemd_unit" ];
              target_label = "unit";
            }];
          }] ++ extra_scrape_configs;
        };
      };
    promtail_scrapers = {
      caddy = { path ? "/var/log/caddy/*.log" }: {
        job_name = "caddy";
        static_configs = [{ targets = [ "localhost" ]; labels = { job = "caddylogs"; __path__ = path; }; }];
      };
    };
    prometheus_exporters = _: {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        port = ports.prometheus_node_exporter;
      };
    };
  };
}
