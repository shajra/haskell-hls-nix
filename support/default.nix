let

    sources = import ../sources;
    pkgs = import sources.nixpkgs-stable { config = {}; overlays = []; };
    nix-project = import sources.nix-project;

in nix-project // { inherit pkgs; }

