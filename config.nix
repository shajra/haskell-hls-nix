{
    ghcVersion = "ghc8104";
    hls.unstable = false;

    haskell-nix.checkMaterialization = false;
    # DESIGN: https://github.com/input-output-hk/hackage.nix/blob/master/index-state-hashes.nix
    haskell-nix.hackage.index = {
        state = "2021-02-20T00:00:00Z";
        sha256 = "74b361a53bd41e1378fceb274b76a461b2e9791fec8bc61aa0b5768d5c930360";
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
