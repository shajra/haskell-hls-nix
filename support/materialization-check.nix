let
    build = import ../.;
    get = ghcVersion: hlsUnstable:
        (build { inherit ghcVersion hlsUnstable; checkMaterialization = true; });
    getBoth = ghcVersion:
        []
        ++ [(get ghcVersion false).hls]
        #++ [(get ghcVersion true).hls]
        ;
in
    # DESIGN: Support same GHC versions as IOHK:
    # https://input-output-hk.github.io/haskell.nix/reference/supported-ghc-versions/
    []
    ++ (getBoth "ghc8104")
    #++ (getBoth "ghc884")
    #++ (getBoth "ghc865")
