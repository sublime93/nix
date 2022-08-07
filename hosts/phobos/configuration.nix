{ config, pkgs, ... }:
let
  hostname = "phobos";
  common = import ../common.nix { inherit config pkgs; };
in
{
  imports = [
    "${common.home-manager}/nixos"
    ./hardware-configuration.nix
  ];

  inherit (common) zramSwap swapDevices;

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
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
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
  networking.interfaces.eth0.useDHCP = true;
  networking.firewall.enable = false;

  users.users.root.hashedPassword = "!";
  users.mutableUsers = false;
  users.users.jacobi = {
    inherit (common) extraGroups;
    isNormalUser = true;
    passwordFile = "/etc/passwordFile-jacobi";

    openssh.authorizedKeys.keys = with common.pubkeys; [ charon mars ] ++ usual;
  };

  services = {
    k3s = {
      enable = true;
      role = "server";
      extraFlags = "--no-deploy traefik";
    };
  } // common.services;
  virtualisation.docker.enable = true;

  # https://github.com/NixOS/nixpkgs/issues/103158
  systemd.services.k3s.after = [ "network-online.service" "firewall.service" ];
  systemd.services.k3s.serviceConfig.KillMode = pkgs.lib.mkForce "control-group";

  system.stateVersion = "22.11";
  security.sudo = common.security.sudo;
  programs.command-not-found.enable = false;
}
