{ inputs, pkgs, ... }:
{
  services.home-assistant.customComponents = [
    (pkgs.stdenv.mkDerivation rec {
      pname = "home-assistant-variables";
      version = "0.15.0";
      src = pkgs.fetchFromGitHub {
        owner = "snarky-snark";
        repo = "home-assistant-variables";
        rev = "v${version}";
        sha256 = "sha256-HKO73B8kARuJxUv8bc0TVvpWQHXeYMe+OncodL8LpP8=";
      };

      installPhase = ''
        cp -r custom_components/var $out
      '';
    })
  ];
  services.home-assistant.customCards = {
    "lovelace-multiline-text-input-card.js" = pkgs.stdenv.mkDerivation {
      name = "lovelace-multiline-text-input-card.js";
      src = pkgs.fetchFromGitHub {
        owner = "faeibson";
        repo = "lovelace-multiline-text-input-card";
        rev = "1.0.4";
        sha256 = "sha256-nuVijc5vuzKlMCjy/DNaZgzNnl11CXlwyLX5H9fNoH4=";
      };

      installPhase = ''
        install -m644 lovelace-multiline-text-input-card.js $out
      '';
    };
  };
}
