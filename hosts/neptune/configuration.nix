{ config, pkgs, ... }:
let
  hostname = "neptune";
  common = import ../common.nix { inherit config pkgs; };
in
{
  imports = [
    "${common.home-manager}/nixos"
    ./hardware-configuration.nix
    ./api.nix
  ];

  inherit (common) zramSwap;

  nix = common.nix // {
    nixPath = [
      "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
      "nixos-config=/home/jacobi/cfg/hosts/${hostname}/configuration.nix"
      "/nix/var/nix/profiles/per-user/root/channels"
    ];
  };

  home-manager.users.jacobi = common.jacobi;
  nixpkgs.pkgs = common.pinned;

  boot = {
    loader = {
      grub.enable = true;
      grub.version = 2;
      grub.device = "/dev/nvme0n1";
    };
    kernel.sysctl = {
      "fs.inotify.max_user_watches" = "1048576";
      "fs.inotify.max_queued_events" = "1048576";
      "fs.inotify.max_user_instances" = "1048576";
    };
    tmpOnTmpfs = true;
  };

  environment.variables = {
    NIX_HOST = hostname;
    NIXOS_CONFIG = "/home/jacobi/cfg/hosts/${hostname}/configuration.nix";
  };

  time.timeZone = common.timeZone;

  networking.hostName = hostname;
  networking.useDHCP = false;
  networking.interfaces.enp9s0.useDHCP = true;
  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" ];
    allowedTCPPorts = with common.ports; [ ] ++ usual;
    allowedUDPPorts = [ ];
  };

  users.mutableUsers = false;
  users.users.root.hashedPassword = "!";
  users.users.jacobi = {
    inherit (common) extraGroups;
    isNormalUser = true;
    passwordFile = "/etc/passwordFile-jacobi";

    openssh.authorizedKeys.keys = with common.pubkeys; [
      m1max
    ] ++ usual;
  };

  environment.systemPackages = [ pkgs.k3s ];

  services = {
    k3s = {
      enable = true;
      role = "server";
    };
    # keycloak = {
    #   enable = true;
    #   httpPort = "8001";
    #   httpsPort = "8002";
    #   frontendUrl = "auth.cobi.dev/auth/";
    #   database = {
    #     host = "yuga.db.cobi.dev";
    #     port = 5433;
    #     passwordFile = "/etc/default/keycloak/pass";
    #     useSSL = false;
    #     # caCert = /etc/default/keycloak/cert;
    #   };
    # };
    caddy = {
      enable = true;
      package = pkgs.xcaddy;
      email = common.emails.personal;
      virtualHosts = {
        # "auth.cobi.dev" = {
        #   extraConfig = ''
        #     reverse_proxy /* {
        #       to localhost:8001
        #     }
        #   '';
        # };
        "home.cobi.dev" = {
          extraConfig = ''
            reverse_proxy /* {
              to home:${toString common.ports.home-assistant}
            }
          '';
        };
        "netdata.cobi.dev" = {
          extraConfig = ''
            reverse_proxy /* {
              to localhost:${toString common.ports.netdata}
            }
          '';
        };
        "flix.cobi.dev" = {
          extraConfig = ''
            reverse_proxy /* {
              to jupiter:${toString common.ports.plex}
            }
          '';
        };
        "flix2.cobi.dev" = {
          extraConfig = ''
            reverse_proxy /* {
              to jupiter:${toString common.ports.jellyfin}
            }
          '';
        };
        "cobi.dev" = {
          extraConfig = ''
            route /static/* {
              s3proxy {
                bucket "jacobi-static"
                force_path_style
              }
            }
            route / {
              redir https://github.com/jpetrucciani/
            }
          '';
        };
        "api.cobi.dev" = {
          extraConfig = ''
            reverse_proxy /* {
              to localhost:10000
            }
          '';
        };
        "nix.cobi.dev" = {
          extraConfig = ''
            route / {
              redir https://github.com/jpetrucciani/nix
            }
            route /up {
              redir https://raw.githubusercontent.com/jpetrucciani/nix/main/scripts/nixup.sh
            }
            route /os-up {
              redir https://github.com/samuela/nixos-up/archive/main.tar.gz
            }
          '';
        };
        "home.petro.casa" = {
          extraConfig = ''
            reverse_proxy /* {
              to petro.casa:${toString common.ports.home-assistant}
            }
          '';
        };
      };
    };
  } // common.services;
  virtualisation.docker.enable = true;

  system.stateVersion = "22.05";
  security.sudo = common.security.sudo;
  security.acme = {
    acceptTerms = true;
    defaults.email = common.emails.personal;
  };
  programs.command-not-found.enable = false;
}
