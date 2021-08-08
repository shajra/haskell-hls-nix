{
    ghcVersion = "8.10.4";
    hls.unstable = false;

    haskell-nix.checkMaterialization = false;
    # DESIGN: https://github.com/input-output-hk/hackage.nix/blob/master/index-state-hashes.nix
    haskell-nix.hackage.index = {
        state = "2021-08-08T00:00:00Z";
        sha256 = "e8aed582a6afc4a82127cdbc976d3aac700a4660fc1c4770170c3fe0443bea68";
    };
    haskell-nix.nixpkgs-pin = {
       # DESIGN: default to "nixpkgs-unstable"
       # DESIGN: see https://github.com/input-output-hk/haskell.nix/blob/master/ci.nix#L26-L38
       ghc865 = "nixpkgs-2105";
       ghc8105 = "nixpkgs-2105";
    };
}
