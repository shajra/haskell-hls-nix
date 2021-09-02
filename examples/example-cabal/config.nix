{
    # In Nixpkgs, GHC version A.B.C is identified as “ghcABC”.
    #
    nixpkgsGhcVersion = "ghc8106";

    # We need to pick the version of HLS that has been built for the right
    # version of GHC (should match nixpkgsGhcVersion above).
    #
    hlsGhcVersion = "8.10.6";

    # If ‘true’, use recent commit of “main” branch for HLS, else the latest
    # official release
    #
    hlsUnstable = true;
}
