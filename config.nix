{
    ghcVersion = "ghc8104";
    hls.unstable = false;

    haskell-nix.checkMaterialization = false;
    # DESIGN: https://github.com/input-output-hk/hackage.nix/blob/master/index-state-hashes.nix
    haskell-nix.hackage.index = {
        state = "2021-05-22T00:00:00Z";
        sha256 = "a154e09d3065552f413f83de105a230a3655f7f91058277a87b8d37ac1698587";
    };
    haskell-nix.nixpkgs-pin = "nixpkgs-2009";
}
