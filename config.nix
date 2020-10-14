{
    ghcVersion = "ghc884";
    haskell-nix.useMaterialization = false;
    haskell-nix.checkMaterialization = false;
    haskell-nix.hackage.index = {
        state = "2020-10-19T00:00:00Z";
        sha256 = "03a98qiqr53csy59pwgbfvnzg90ikaiz9gvxv6s9aw95f990z9mb";
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
