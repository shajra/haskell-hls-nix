{
    ghcVersion = "ghc884";
    haskell-nix.useMaterialization = false;
    haskell-nix.checkMaterialization = false;
    haskell-nix.hackage.index = {
        state = "2020-08-08T00:00:00Z";
        sha256 = "0ikr39gh3l4r4d26227p69akg78ckml464jcz0p0c257ivbyzppw";
    };
    haskell-nix.nixpkgs-pin = "nixpkgs-2003";
    haskell-nix.plan = {
        # DESIGN: a "<packagename>.sha256" property will set the plan's hash
        # DESIGN: a "<packagename>.check" property will check materialization
        # IDEA: when ready: https://github.com/digital-asset/ghcide/issues/113
        #ghcide.sha256 = "0000000000000000000000000000000000000000000000000000";
        #ghcide.check = true;
    };
}
