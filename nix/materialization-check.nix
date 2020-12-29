let

    nixpkgs = import (import ./sources).nixpkgs-stable {
        config = {};
        overlays = [];
    };

    lib = nixpkgs.lib;

    instabilities = [
        false
        true
    ];

    ghcVersions = [
        "ghc865"
        "ghc883"
        "ghc884"
        "ghc8101"
        "ghc8102"
    ];

in builtins.concatMap (ghcVersion:
    builtins.map (hlsUnstable:
        let build = (import ../.) {
                inherit ghcVersion hlsUnstable;
                useMaterialization = true;
                checkMaterialization = true;
            };
        in build.hls
    ) instabilities
) ghcVersions
