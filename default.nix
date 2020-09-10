{ sources ? import ./sources
, config ? import ./config.nix
, useMaterialization ? config.haskell-nix.useMaterialization
, checkMaterialization ? config.haskell-nix.checkMaterialization
, nixpkgs-pin ? config.haskell-nix.nixpkgs-pin
, index-state ? config.haskell-nix.hackage.index.state
, index-sha256 ? config.haskell-nix.hackage.index.sha256
, ghcVersion ? config.ghcVersion
}:

let

    nixpkgs =
        let hn = import sources."haskell.nix" {};
            nixpkgsSrc = hn.sources."${nixpkgs-pin}";
            nixpkgsOrigArgs = hn.nixpkgsArgs;
            nixpkgsArgs = nixpkgsOrigArgs // {
                config = {};
                overlays = nixpkgsOrigArgs.overlays ++ [(self: super: {
                    alex = super.haskellPackages.alex;
                    happy = super.haskellPackages.happy;
                })];
            };
        in import nixpkgsSrc nixpkgsArgs;

    haskell-nix = nixpkgs.haskell-nix;

    planConfigFor = name: modules:
        let plan-sha256 = config.haskell-nix.plan."${name}".sha256 or null;
            materialized = ./materialized + "/${name}";
            isMaterialized = builtins.pathExists materialized
                && useMaterialization;
            check = config.haskell-nix.plan."${name}".check
                or checkMaterialization;
        in {
            inherit name modules index-state index-sha256;
            compiler-nix-name = ghcVersion;
            ${if plan-sha256 != null then "plan-sha256" else null} =
                plan-sha256;
            ${if isMaterialized then "materialized" else null} =
                materialized;
            ${if isMaterialized then "checkMaterialization" else null} =
                check;
        };

    allExes = pkg: pkg.components.exes;

    fromSource = name: modules:
        let planConfig = planConfigFor name modules // {
                src = sources."${name}";
            };
        in allExes (haskell-nix.cabalProject planConfig)."${name}";

    build = fromSource "haskell-language-server"
        [{ enableSeparateDataOutput = true; }];

    trueVersion = {
        "ghc844" = "8.4.4";
        "ghc861" = "8.6.1";
        "ghc862" = "8.6.2";
        "ghc863" = "8.6.3";
        "ghc864" = "8.6.4";
        "ghc865" = "8.6.5";
        "ghc881" = "8.8.1";
        "ghc882" = "8.8.2";
        "ghc883" = "8.8.3";
        "ghc884" = "8.8.4";
        "ghc8101" = "8.10.1";
        "ghc8102" = "8.10.2";
    }."${ghcVersion}" or (throw "unsupported GHC Version: ${ghcVersion}");

    longDesc = suffix: ''
        Haskell Language Server (HLS) is the latest attempt make an IDE-like
        experience for Haskell that's compatible with different editors. HLS
        implements Microsoft's Language Server Protocol (LSP). With this
        approach, a background service is launched for a project that answers
        questions needed by an editor for common IDE features.

        Note that you need a version of HLS compiled specifically for the GHC
        compiler used by your project.  If you have multiple versions of GHC and
        HLS installed in your path, then a provided wrapper can be used to
        select the right one for the version of GHC used by your project.

        ${suffix}
    '';

    hls = build.haskell-language-server.overrideAttrs (old: {
        name = "haskell-language-server-${ghcVersion}";
        meta = old.meta // {
            description =
                "Haskell Language Server (HLS) for GHC ${trueVersion}";
            longDescription = ''
        This package provides the server executable compiled against
        ${trueVersion}.  It has the name original name of
        "haskell-language-server," which may clash with versions compiled for
        other compilers.
        '';
        };
    });

    hls-renamed = nixpkgs.stdenv.mkDerivation {
        name = "haskell-language-server-${ghcVersion}-renamed";
        version = hls.version;
        phases = ["installPhase"];
        nativeBuildInputs = [nixpkgs.makeWrapper];
        installPhase = ''
            mkdir --parents $out/bin
            makeWrapper \
                "${hls}/bin/haskell-language-server" \
                "$out/bin/haskell-language-server-${trueVersion}"
        '';
        meta = hls.meta // {
            description =
                "Haskell Language Server (HLS) for GHC ${trueVersion}, renamed binary";
            longDescription = ''
        This package provides the server executable compiled against
        ${trueVersion}.  The binary has been renamed from
        "haskell-language-server" to "haskell-language-server-${ghcVersion}" to
        allow Nix to install multiple versions to the same profile for those
        that wish to use the HLS wrapper.
        '';
        };
    };

    hls-wrapper = build.haskell-language-server-wrapper.overrideAttrs (old: {
        name = "haskell-language-server-${ghcVersion}-wrapper";
        meta = old.meta // {
            description = "Haskell Language Server (HLS) wrapper";
            longDescription = "This package provides the server wrapper.";
        };
    });

in {
    inherit
    haskell-nix
    hls
    hls-wrapper
    hls-renamed;
}
