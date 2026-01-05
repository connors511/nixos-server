
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko --flake .#svr1

sudo mkdir -p /mnt/persist/etc/ssh
sudo ssh-keygen -t ed25519 -N "" -C "" -f /mnt/persist/etc/ssh/ssh_host_ed25519_key
nix-shell -p ssh-to-age --run 'cat /mnt/persist/etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age'

echo -e "\n\033[1;32mAll steps completed successfully. NixOS is now ready to be installed.\033[0m\n"
echo -e "Remember to add the server's host public key to sops-nix before installing!"
echo -e "To install NixOS configuration for hostname, run the following command:\n"

echo -e "\033[1msudo nixos-install --no-root-passwd --root /mnt --flake github:eh8/chenglab#hostname\033[0m\n"
