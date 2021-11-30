{ config, pkgs, ... }:
let
  home-manager = fetchTarball "https://github.com/nix-community/home-manager/archive/release-21.11.tar.gz";
  jacobi = import ../home.nix;
in
{
  inherit jacobi home-manager;

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      max-jobs = auto
      extra-experimental-features = nix-command flakes
    '';
  };

  pubkeys = rec {
    # physical
    galaxyboss = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO9u9+khlywG0vSsrTsdjZEhKlKBpXx8RnwESGw+zIKI galaxyboss";
    megaboss = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEhhl/jKYcglH7+tTYgsVRKqVuf7hwF6yOgpdYIQWAyJ jacobi-megaboss";

    # servers
    hyperion = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICO5xk+gAyX4aKH7jpVDCIanXhezhK7XuaFOSJY+Xf1k jacobi@hyperion";
    tethys = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAKqBsfhg4qbm3/aXV+6hy2oaWqouT63MDkwNc6E3pwd jacobi@tethys";
    mimas = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIbBo1RRXmMm8GBVzaoM27hgoMuNB+bsXJLSUj6xuxEQ armboss";
    titan = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDKnCuUSP/RbAfUvNkD43wm6w5dhsfdIgSqawj9Z0UQX jacobi@titan";
    jupiter = "";
    saturn = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPY2sNJE5ysSTeFzTv2U+zIeIB5LMhbUaP+yC5VDgEHD jacobi@saturn";
    home = "";

    # android
    s21 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICLuqazOtTUHVkywIMHWXizCLmSaEl2C8Oyb9t5LmslD jacobi@s21";
    zfold3 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKuFnEC93wi/fjHE4oAK1A59HkFltRSfHTZelB4AR29u jacobi@zfold3";

    # ios
    ipad = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAQhTANgPfe2Xyw14LjxUyhBmVi/7MJwONf99JvmZrIy jacobi-ipad";

    # laptop
    pluto = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEgmAVUZdA5QrsCQFYhL0bf+NbXowV9M12PPiwoWRMJK jacobi@pluto";
    work = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIlB0yckw0Q9WV3/C/teeOn+McN5vJRsuCqKH4b9zm4W Jacobi Petrucciani (gitlab.medable.com)";

    desktop = [
      galaxyboss
      megaboss
    ];

    server = [
      hyperion
      tethys
      mimas
      titan
      jupiter
      saturn
      home
    ];

    android = [
      s21
      zfold3
    ];

    ios = [
      ipad
    ];

    mobile = android ++ ios;

    laptop = [
      pluto
      work
    ];

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
      Defaults env_keep+=NIXOS_CONFIG
    '';
    wheelNeedsPassword = false;
  };

  services = {
    tailscale.enable = true;
  };

  timeZone = "America/Indiana/Indianapolis";

  zramSwap = {
    enable = true;
    memoryPercent = 100;
  };
}
