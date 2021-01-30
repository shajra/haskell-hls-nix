{
    ghcVersion = "ghc884";
    hackage.version.implicit-hie = "0.1.2.5";
    hls.unstable = false;

    haskell-nix.checkMaterialization = false;
    # DESIGN: https://github.com/input-output-hk/hackage.nix/blob/master/index-state-hashes.nix
    haskell-nix.hackage.index = {
        state = "2021-01-24T00:00:00Z";
        sha256 = "072c1d30ac3111a527f6647c8b646c0774fe382269a902c9e6e4fc1c18772f31";
    };
    haskell-nix.nixpkgs-pin = "nixpkgs-2009";

    # DESIGN: Support same GHC versions as IOHK:
    # https://input-output-hk.github.io/haskell.nix/reference/supported-ghc-versions/
    haskell-nix.plan = {
        # DESIGN: a "<packagename>.sha256" property will set the plan's hash
        # DESIGN: a "<packagename>.check" property will check materialization
        #hls-released-ghc865.sha256  = "1d0dxdph9h4hc46vdpjs7snf5nhfir86hd3klxqixc2s17rx8nkx";
        #hls-released-ghc883.sha256  = "0xidhpdkgx5pj7fdp95zfr5gihbagciggbxn7hgr4klq0f86k4ia";
        #hls-released-ghc884.sha256  = "0xc9imlwlp167xyyx1l3mxk03526w97arx6fhnck6m6bjp1ih5fp";
        #hls-released-ghc8102.sha256 = "1m49si4cp932ci4av4sxpp1zi47ljqhrbbsgs1aka1hfibgd1qpb";
        #hls-released-ghc8103.sha256 = "0n8afxmlzassix3j4wwnnkzdxqj3d2nnkchf7hijwnvcflmrp72v";
        #hls-unstable-ghc865.sha256  = "0jbkbxw9wbd09qqn498xg9ww2ij11ha1d7bfj1ar3mkf6psn55dm";
        #hls-unstable-ghc883.sha256  = "0qb63nm4w872d7hlfrcx1lyqm53hppipirx0vsvcyjwy0s18wdn9";
        #hls-unstable-ghc884.sha256  = "0k536klq0z86ppq6ki7caqjixjzv5d8pc8mby8cldln9i4i3si9b";
        #hls-unstable-ghc8102.sha256 = "1m5gdbyg0hz5ph0w1q7gbb496r4ylf2vi2f3mmzd1cbgy0930q63";
        #hls-unstable-ghc8103.sha256 = "0xd99v7m3d22j98nnnf4fh94k0x4ylcjkafmjhc3lhrd2mgc3y8v";
        #implicit-hie.sha256 = "0yk0v09ad3bjkrk24fnyfkhja7v0a3b1r1bzbfg1kyym87fh8aa6";
    };

    haskell-nix.lookupSha256.unstable = {
        "https://github.com/alanz/ghc-exactprint.git" =
            "18r41290xnlizgdwkvz16s7v8k2znc7h215sb1snw6ga8lbv60rb";
    };
}
