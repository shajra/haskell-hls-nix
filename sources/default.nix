let

    srcs = import ./sources.nix;

    lib = (import srcs.nixpkgs { config = {}; overlays = []; }).lib;

    isDarwin = builtins.elem builtins.currentSystem lib.systems.doubles.darwin;

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

    darwinizedSrcs =
        if isDarwin
        then srcs // { nixpkgs-stable = srcs.nixpkgs-stable-darwin; }
        else srcs // { nixpkgs-stable = srcs.nixpkgs-stable-linux ; };

    overrides = {
        haskell-language-server = fromGitHub
            sources.haskell-language-server
            "haskell-language-server-src";
    };

in darwinizedSrcs // overrides
