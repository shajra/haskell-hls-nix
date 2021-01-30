{
    ghcVersion = "ghc8103";
    hackage.version.implicit-hie = "0.1.2.5";
    hls.unstable = false;

    haskell-nix.checkMaterialization = false;
    # DESIGN: https://github.com/input-output-hk/hackage.nix/blob/master/index-state-hashes.nix
    haskell-nix.hackage.index = {
        state = "2021-01-30T00:00:00Z";
        sha256 = "fa890b301aa2e30eed8a0a62e87210eeb3179d97f184e5aaa338516cc07a8e4a";
    };
    haskell-nix.nixpkgs-pin = "nixpkgs-2009";

    haskell-nix.lookupSha256.unstable = {
        "https://github.com/alanz/ghc-exactprint.git" =
            "18r41290xnlizgdwkvz16s7v8k2znc7h215sb1snw6ga8lbv60rb";
    };

    haskell-nix.lookupSha256.released = {
        "https://github.com/alanz/ghc-exactprint.git" =
            "18r41290xnlizgdwkvz16s7v8k2znc7h215sb1snw6ga8lbv60rb";
    };
}
