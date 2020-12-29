{
    ghcVersion = "ghc884";
    hackage.version.implicit-hie = "0.1.2.5";
    hls.unstable = false;

    haskell-nix.useMaterialization = true;
    haskell-nix.checkMaterialization = false;
    # DESIGN: https://github.com/input-output-hk/hackage.nix/blob/master/index-state-hashes.nix
    haskell-nix.hackage.index = {
        state = "2020-12-28T00:00:00Z";
        sha256 = "ce5696846e316c2d151c69f5f292dfe1aceca540253757831d9081990a2a1d90";
    };
    haskell-nix.nixpkgs-pin = "nixpkgs-2009";

    # DESIGN: Support same GHC versions as IOHK:
    # https://input-output-hk.github.io/haskell.nix/reference/supported-ghc-versions/
    haskell-nix.plan = {
        # DESIGN: a "<packagename>.sha256" property will set the plan's hash
        # DESIGN: a "<packagename>.check" property will check materialization
        hls-released-ghc865.sha256  = "1lv1v3k6ni8f4bbnrxnl75aysnch5rj40y1czr2l7fqy70bjljv8";
        hls-released-ghc883.sha256  = "0qm0a6nxx3h6z5j39j3038qvp6qnddzxny9hqvzqvligrgkypnwp";
        hls-released-ghc884.sha256  = "0rm2z4qvhgbiq7w7kymf61inyj1g7hw3w0j37aj3yi9dn61jhcz4";
        hls-released-ghc8101.sha256 = "1iv7y6707vrmzlzrf900xqarymwl2ca2wcmb50hfcxq3wh16j7mh";
        hls-released-ghc8102.sha256 = "06ilaf4z30w0a1avf7f87zib37199ndfdbkvincbyvjm2z6nwr10";
        hls-unstable-ghc865.sha256  = "0kq8k8m4pr1ifspamr59m8rd5l6v023anj2lxlcmnp74p8y9g2n5";
        hls-unstable-ghc883.sha256  = "19lig0rjd9r2224ggksp1a1xy93zpzdh556y8hh76rbp81mmjzwf";
        hls-unstable-ghc884.sha256  = "0dnlqy7c9qpqi2m5gs1172hn10j0y9663hcs0i3ndkypbj68rb1s";
        hls-unstable-ghc8101.sha256 = "0swn2faj8f98agi8cskirndyhlyj7cdg3imgml1g1hbmd5mn0p0d";
        hls-unstable-ghc8102.sha256 = "0jys0gnbqbbyrfv8pzlm9gsgj9aijlm5xnm97bqrg7r3nv4fl5n8";
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
