{
    # In Nixpkgs, GHC version A.B.C is identified as "ghcABC".  For a Stack
    # build, this version must match the version specified stack.yaml (generally
    # set by the resolver setting).
    #
    ghcVersion = "ghc8103";

    # If 'true', use recent commit of master branch for HLS, else the latest
    # official release
    #
    hlsUnstable = false;
}
