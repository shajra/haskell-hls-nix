let
    build = import ../nix;
    get = ghcVersion: hlsUnstable:
        (build {
            inherit ghcVersion hlsUnstable;
            checkMaterialization = true;
        }).distribution;
    getBoth = ghcVersion:
        []
        ++ [(get ghcVersion false).hls]
        ++ [(get ghcVersion true).hls]
        ;
in
    # DESIGN: Support same GHC versions as IOHK:
    # https://input-output-hk.github.io/haskell.nix/reference/supported-ghc-versions/
    []
    ++ (getBoth "8.10.7")
    ++ (getBoth "8.10.6")
    ++ (getBoth "8.8.4")
    ++ (getBoth "8.6.5")
