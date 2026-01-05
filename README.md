# nixos-server
Configuration files for my NixOS server. Follow the Nixos as a Server series at [my blog](https://guekka.github.io)



##
Make a password using `echo "password" | mkpasswd -m SHA-512` and put in the secrets file for the user password.

Run ./scripts/install-disko.sh on the server.

Copy the age key to the .sops.yaml file and rekey the secrets with `just secrets-sync`.

Upload the files to the server or push the repo to git. Pull on the server, and run nixos-install.



Get a cloudflared cert.pem file by logging in; `cloudflared tunnel login`.
Generate the credentials file using: `cloudflared tunnel token --cred-file /tmp/mysecret.json <TUNNEL>`



## Borg
Get a storage box on Hetzner. Enable SSH access. Copy public key to server;
`echo '<PUBLIC KEY>' | ssh -p23 uXXXXX@uXXXXX.your-storagebox.de install-ssh-key`

`nix-shell -p borgmatic`

`sudo borg init --encryption=repokey --append-only ssh://uXXXXXX@uXXXXXX.your-storagebox.de/./shared --rsh 'ssh -i /run/secrets/<SSH KEY NAME>'`
