{
    ghcVersion = "8.10.4";
    hls.unstable = false;

    haskell-nix.checkMaterialization = false;
    # DESIGN: https://github.com/input-output-hk/hackage.nix/blob/master/index-state-hashes.nix
    haskell-nix.hackage.index = {
        state = "2021-07-25T00:00:00Z";
        sha256 = "d01e60cc933f805b6f5e85d128f445cd07dbf12b14f010ee71c6dadd1bd9626b";
    };
    haskell-nix.nixpkgs-pin = {
       # DESIGN: default to "nixpkgs-unstable"
       # DESIGN: see https://github.com/input-output-hk/haskell.nix/blob/master/ci.nix#L26-L38
       ghc865 = "nixpkgs-2105";
       ghc8105 = "nixpkgs-2105";
    };
}
