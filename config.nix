{
    ghcVersion = "ghc884";
    haskell-nix.useMaterialization = false;
    haskell-nix.checkMaterialization = false;
    haskell-nix.hackage.index = {
        state = "2020-08-07T11:45:57Z";
        sha256 = "0rsj92534bmpvl9byvzrqrxwnqlapgbawk3gnssb4p8sm7iwnhbn";
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
