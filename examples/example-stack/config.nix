{
    # In Nixpkgs, GHC version A.B.C is identified as “ghcABC”.  For a Stack
    # build, this version must match the version specified stack.yaml (generally
    # set by the resolver setting).
    #
    nixpkgsGhcVersion = "ghc8107";

    # We need to pick the version of HLS that has been built for the right
    # version of GHC (should match nixpkgsGhcVersion above).
    #
    hlsGhcVersion = "8.10.7";

    # If ‘true’, use recent commit of “main” branch for HLS, else the latest
    # official release
    #
    hlsUnstable = false;
}
