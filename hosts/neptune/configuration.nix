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
    allowedTCPPorts = with common.ports; [
      # k3s?
      6443
    ] ++ usual;
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
    caddy =
      let
        reverse_proxy = location: {
          extraConfig = ''
            import GEOBLOCK
            reverse_proxy /* {
              to ${location}
            }
          '';
        };
      in
      {
        enable = true;
        package = pkgs.xcaddy;
        email = common.emails.personal;

        # countries from here http://www.geonames.org/countries/
        globalConfig = ''
          (GEOBLOCK) {
            @geoblock {
              not maxmind_geolocation {
                db_path "{env.GEOIP_DB}"
                allow_countries US CA GM
              }
              not remote_ip 127.0.0.1
            }
            respond @geoblock 403
          }
        '';
        virtualHosts = {
          "api.cobi.dev" = reverse_proxy "localhost:10000";
          "auth.cobi.dev" = reverse_proxy "localhost:8080";
          "home.cobi.dev" = reverse_proxy "home:${toString common.ports.home-assistant}";
          "netdata.cobi.dev" = reverse_proxy "localhost:${toString common.ports.netdata}";
          "flix.cobi.dev" = reverse_proxy "jupiter:${toString common.ports.plex}";
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

  system.stateVersion = "22.11";
  security.sudo = common.security.sudo;
  security.acme = {
    acceptTerms = true;
    defaults.email = common.emails.personal;
  };
  programs.command-not-found.enable = false;
}
