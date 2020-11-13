{
    ghcVersion = "ghc884";
    hackage.version.implicit-hie = "0.1.2.5";
    hls.unstable = false;

    haskell-nix.useMaterialization = true;
    haskell-nix.checkMaterialization = false;
    haskell-nix.hackage.index = {
        state = "2020-12-21T00:00:00Z";
        sha256 = "6d2af09cd26716143017741ec319e21e47421419506f9c373df28f029b63d8b1";
    };
    haskell-nix.nixpkgs-pin = "nixpkgs-2009";

    # DESIGN: Support same GHC versions as IOHK:
    # https://input-output-hk.github.io/haskell.nix/reference/supported-ghc-versions/
    haskell-nix.plan = {
        # DESIGN: a "<packagename>.sha256" property will set the plan's hash
        # DESIGN: a "<packagename>.check" property will check materialization
        hls-released-ghc865.sha256  = "1gj14zqfb9lm4xlvz6jvprsb2x1viwx393c2ph08x8l3v8vcrn4n";
        hls-released-ghc883.sha256  = "0h993j32wpbjvmzjiphjqc5q5rklw2q63qc5ai3iw9x0bbadp5qc";
        hls-released-ghc884.sha256  = "0rll74f8xxnmsb3a8srkmxhpnzf0fm33ccc1f4kgb6yzpasx2w7y";
        hls-released-ghc8101.sha256 = "1bhmdzmgc1ri95r6nn6152m3zpmx5danr0j9xz8lw8hqgk7bnl8y";
        hls-released-ghc8102.sha256 = "07k8h18q4dvd6xin29sj17pvlqbhzvpjxhqh7qibsr642qjh4vfb";
        hls-unstable-ghc865.sha256  = "08ckay3yf8g808zxabqvqz0fb0hsvrhmvk6cqhgr3c1rzl4y2l51";
        hls-unstable-ghc883.sha256  = "0z3lx9l6p5g1q734lfg4x3p6igaak3zgqkzmgaykr0f24qcm79x1";
        hls-unstable-ghc884.sha256  = "1i6ip3n4jvbg17qm0hdjxfyb06n771ya4xavrbyr9rw3wzikpv48";
        hls-unstable-ghc8101.sha256 = "193p5k7yd5a2ylr1r32awvaj25b4ygf1w3bg319f7nbnhnisd7ji";
        hls-unstable-ghc8102.sha256 = "1frylxf89wg2vgddqgg99cbvg2sxmw83cy69p8zwh6ixhg0hn0il";
        implicit-hie.sha256 = "0yk0v09ad3bjkrk24fnyfkhja7v0a3b1r1bzbfg1kyym87fh8aa6";
    };

    haskell-nix.lookupSha256.released = {
        "https://github.com/bubba/hie-bios.git" =
            "1iqk55jga4naghmh8zak9q7ssxawk820vw8932dhympb767dfkha";
        "https://github.com/bubba/brittany.git" =
            "1rkk09f8750qykrmkqfqbh44dbx1p8aq1caznxxlw8zqfvx39cxl";
    };

    haskell-nix.lookupSha256.unstable = {
        "https://github.com/bubba/hie-bios.git" =
            "1iqk55jga4naghmh8zak9q7ssxawk820vw8932dhympb767dfkha";
        "https://github.com/bubba/brittany.git" =
            "1rkk09f8750qykrmkqfqbh44dbx1p8aq1caznxxlw8zqfvx39cxl";
    };
}
