#!/usr/bin/env bash

# curl is a default package
curl https://raw.githubusercontent.com/adamstaveley/nixos-conf/main/configuration.nix > configuration.nix

# overwrite default configuration
sudo mv configuration.nix /etc/nixos/configuration.nix

# switch to new configuration
sudo nixos-rebuild switch

echo '\nNixOS updated. Start new shell session for Zsh'