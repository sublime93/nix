# ymir

This is a bare-metal nixos laptop!

## bootstrap

```bash
# load nixos graphical iso, run installer

# generate ssh key, add to github
ssh-keygen -o -a 100 -t ed25519 -C "jacobi@ymir"

# clone repo
nix-shell -p git
git clone git@github.com:jpetrucciani/nix.git ~/cfg
cd ~/cfg

# initial switch
export HOSTNAME='ymir'
$(nix-build --no-link --expr 'with import ~/cfg {}; _nixos-switch' --argstr host "$HOSTNAME")/bin/switch
```

---

## In this directory

### [configuration.nix](./configuration.nix)

This file defines the OS configuration for the `ymir` machine.

### [hardware-configuration.nix](./hardware-configuration.nix)

This is an auto-generated file that configures disks and other plugins for nixos.
