default:
  just --list

deploy machine ip='':
  #!/usr/bin/env sh
  if [ {{machine}} = "macos" ]; then
    darwin-rebuild switch --flake .
  elif [ -z "{{ip}}" ]; then
    sudo nixos-rebuild switch --fast --flake ".#{{machine}}"
  else
    nix run nixpkgs#nixos-rebuild -- switch --fast --flake ".#{{machine}}" --target-host "mlarsen@{{ip}}" --use-remote-sudo --build-host "mlarsen@{{ip}}"
  fi

boot machine:
    sudo nixos-rebuild boot --fast --flake ".#{{machine}}"

up:
  nix flake update

lint:
  # statix check .
  nix run nixpkgs#statix -- check .

gc:
  sudo nix profile wipe-history --profile /nix/var/nix/profiles/system --older-than 7d && sudo nix store gc

repair:
  sudo nix-store --verify --check-contents --repair

secrets-edit host='common':
  sops hosts/{{host}}/secrets.yaml

secrets-rotate:
  for file in hosts/*/secrets.yaml; do sops --rotate --in-place "$file"; done

secrets-sync:
  for file in hosts/*/secrets.yaml; do sops updatekeys "$file"; done

build-iso:
  nix build .#nixosConfigurations.iso1chng.config.system.build.isoImage --builders 'ssh://nixos x86_64-linux'

iso:
  nix build .#nixosConfigurations.iso1mlarsen.config.system.build.isoImage --builders 'ssh://nixos x86_64-linux'

sync user='nixos' host='nixos':
    rsync -vaCzh --timeout=5 --delete --exclude=\*.git --exclude=\*.github --exclude=\*.idea --exclude=\*.direnv --exclude=\*.devenv . {{user}}@{{host}}:/home/{{user}}/homelab

ssh:
    ssh mlarsen@svr1.lan
