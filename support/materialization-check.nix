let
    build = import ../.;
    get = ghcVersion: hlsUnstable:
        builtins.removeAttrs
        (build { inherit ghcVersion hlsUnstable; })
        ["nixpkgs"];
    getBoth = ghcVersion: []
        ++ (builtins.attrValues (get ghcVersion true))
        ++ (builtins.attrValues (get ghcVersion false));
in
    []
    ++ (getBoth "ghc865")
    ++ (getBoth "ghc883")
    ++ (getBoth "ghc884")
    ++ (getBoth "ghc8101")
    ++ (getBoth "ghc8102")
