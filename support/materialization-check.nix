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
    []
    ++ (getBoth "ghc865")
    #++ (getBoth "ghc883")
    #++ (getBoth "ghc884")
    #++ (getBoth "ghc8102")
    #++ (getBoth "ghc8103")
