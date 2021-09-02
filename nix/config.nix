{
    haskell-nix.checkMaterialization = false;
    # DESIGN: HLS already pins index-state in the cabal.project file.
    # Specifying the index-state here just overrides that pinning.
    #haskell-nix.hackage.index = {
    #    state = "2021-09-01T00:00:00Z";
    #    sha256 = "934338f5c73d91ee7dfdcb838ac44e8d92d5306aa60582cdded7abae887a7646";
    #};
    haskell-nix.nixpkgs-pin = {
       # DESIGN: default to "nixpkgs-unstable"
       # DESIGN: see https://github.com/input-output-hk/haskell.nix/blob/master/ci.nix#L26-L38
       "8.6.5" = "nixpkgs-2105";
       "8.10.7" = "nixpkgs-2105";
    };
    haskell-nix.lookupSha256.released = {
        "https://github.com/hsyl20/ghc-api-compat" =
            "16bibb7f3s2sxdvdy2mq6w1nj1lc8zhms54lwmj17ijhvjys29vg";
        "https://github.com/haskell/lsp.git" =
            "1whcgw4hhn2aplrpy9w8q6rafwy7znnp0rczgr6py15fqyw2fwb5";
    };
    haskell-nix.lookupSha256.unstable = {
        "https://github.com/hsyl20/ghc-api-compat" =
            "16bibb7f3s2sxdvdy2mq6w1nj1lc8zhms54lwmj17ijhvjys29vg";
        "https://github.com/haskell/lsp.git" =
            "1whcgw4hhn2aplrpy9w8q6rafwy7znnp0rczgr6py15fqyw2fwb5";
    };
}
