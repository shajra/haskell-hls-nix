let

    srcs = import ./sources.nix;

    nixpkgs-bootstrap = import srcs.nixpkgs { config = {}; overlays = []; };
    isDarwin = nixpkgs-bootstrap.stdenv.isDarwin;

    sources = builtins.fromJSON
        (builtins.readFile ./sources.json);

    pkgs = import (import ./sources.nix).nixpkgs {
        config = {};
        overlays = [];
    };

    fromGitHub = source: name:
        with source; pkgs.fetchFromGitHub {
            inherit owner repo rev name sha256;
            fetchSubmodules = true;
        };

    nixpkgs-stable-linux = srcs.nixpkgs;
    nixpkgs-stable-darwin = srcs.nixpkgs-darwin;
    nixpkgs-stable =
        if isDarwin then nixpkgs-stable-darwin else nixpkgs-stable-linux;

    srcsMerged = builtins.removeAttrs (srcs // {
        inherit nixpkgs-stable nixpkgs-stable-linux nixpkgs-stable-darwin;
    }) ["nixpkgs" "nixpkgs-darwin"];

    overrides = {
        hls-released =
            let s = sources.hls-released;
            in fromGitHub s "haskell-hls-${s.branch}-src";
        hls-unstable =
            let s = sources.hls-unstable;
            in fromGitHub s "haskell-hls-${s.branch}-src";
    };

in srcsMerged // overrides
