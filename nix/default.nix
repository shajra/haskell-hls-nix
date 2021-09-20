let

    hnGhc = ghcVersion: {
        "8.6.1"  = "ghc861";
        "8.6.2"  = "ghc862";
        "8.6.3"  = "ghc863";
        "8.6.4"  = "ghc864";
        "8.6.5"  = "ghc865";
        "8.8.1"  = "ghc881";
        "8.8.2"  = "ghc882";
        "8.8.3"  = "ghc883";
        "8.8.4"  = "ghc884";
        "8.10.1" = "ghc8101";
        "8.10.2" = "ghc8102";
        "8.10.3" = "ghc8103";
        "8.10.4" = "ghc8104";
        "8.10.5" = "ghc8105";
        "8.10.6" = "ghc8106";
        "8.10.7" = "ghc8107";
        "9.0.1"  = "ghc901";
    }."${ghcVersion}" or (throw "unsupported GHC Version: ${ghcVersion}");

    npGhc = builtins.replaceStrings ["."] [""];

in

{ externalOverrides ? {}
, config ? import ../config.nix // import ./config.nix
, ghcVersion ? config.ghcVersion
, hlsUnstable ? config.hls.unstable
, checkMaterialization ? config.haskell-nix.checkMaterialization
, nixpkgs-pin ? config.haskell-nix.nixpkgs-pin."${ghcVersion}" or "nixpkgs-unstable"
, index-state ? config.haskell-nix.hackage.index.state or null
, index-sha256 ? config.haskell-nix.hackage.index.sha256 or null
}:

let

    external = import ./external // externalOverrides;

    nix-project = import external.nix-project;

    stability = if hlsUnstable then "unstable" else "released";

    name = "hls-${stability}";

    nixpkgs-stable = import external.nixpkgs-stable {
        config = {};
        overlays = [];
    };

    lib = nixpkgs-stable.lib;

    nixpkgs-unstable = import external.nixpkgs-unstable {
        config = {};
        overlays = [];
    };

    nixpkgs-hn =
        let hn = import external."haskell.nix" {
                # DESIGN: occaisionally useful, not generally
                # sourcesOverride = { hackage = external."hackage.nix"; };
            };
            nixpkgsSrc = hn.sources."${nixpkgs-pin}";
            nixpkgsOrigArgs = hn.nixpkgsArgs;
            nixpkgsArgs = nixpkgsOrigArgs;
        in import nixpkgsSrc hn.nixpkgsArgs;

    haskell-nix = nixpkgs-hn.haskell-nix;

    planConfigFor = compiler-nix-name: modules:
        let isDarwin = nixpkgs-stable.stdenv.isDarwin;
            platformName = if isDarwin then "darwin" else "linux";
            needsNewName = name == "hls-${stability}";
            newName = if needsNewName then "${name}-${compiler-nix-name}" else name;
        in {
            inherit name modules compiler-nix-name
                checkMaterialization;
            configureArgs = "--disable-benchmarks";
            lookupSha256 = {location, ...}:
                config.haskell-nix.lookupSha256."${stability}"."${location}" or null;
            materialized = ./materialized + "-${platformName}/${newName}";
            ${if isNull index-state then null else "index-state"} = index-state;
            ${if isNull index-sha256 then null else "index-sha256"} = index-sha256;
        };

    allExes = pkg: pkg.components.exes;

    defaultModules = [{ enableSeparateDataOutput = true; }];

    # IDEA: This is an incomplete/broken attempt to get a 9.0.1 build working.
    # Just keeping it around for a moment in case I want to try again.
    modifiedHlsSrc =
        let
            orig = external."${name}";
            sed = "${nixpkgs-stable.gnused}/bin/sed";
            modified = nixpkgs-stable.runCommand "${name}-pruned" {} ''
                cp --archive "${orig}" "$out"
                chmod -R +wX "$out"
                "${sed}" --in-place --expression '
                    /hls-brittany-plugin/d
                    /hls-class-plugin/d
                    /hls-fourmolu-plugin/d
                    /hls-refine-imports-plugin/d
                    /hls-splice-plugin/d
                    /hls-stylish-haskell-plugin/d
                    /hls-tactics-plugin/d
                ' "$out/cabal.project"
                echo 'flags: -brittany -class -fourmolu -splice -stylishhaskell -tactic -refineImports' >> \
                    "$out/cabal.project.local"
                echo; echo; echo CABAL.PROJECT
                cat "$out/cabal.project"
                echo; echo; echo CABAL.PROJECT.LOCAL
                cat "$out/cabal.project.local"
            '';
        in if ghcVersion == "9.0.1" then modified else orig;

    planConfig = planConfigFor (hnGhc ghcVersion) defaultModules // {
        src = external."${name}";
        # DESIGN: needed before, might be useful in the future
        #constraints: apply-refact < 0.9.0.0
        #max-backjumps: 10000
        ${if (ghcVersion == "9.0.1") then "cabalProjectLocal" else null} = ''
            flags: -brittany -class -fourmolu -splice -stylishhaskell -tactic -refineImports
        '';
    };

    cabalProject = haskell-nix.cabalProject planConfig;

    updateMaterialized =
        (haskell-nix.cabalProject' planConfig).plan-nix.passthru.updateMaterialized;

    build = allExes cabalProject.haskell-language-server;

    wrapHls = nameSuffix: exeSuffix: meta:
        let exeName = "haskell-language-server${exeSuffix}";
            hls-orig = build.haskell-language-server;
        in nixpkgs-stable.stdenv.mkDerivation {
            name = "haskell-language-server-${hnGhc ghcVersion}${nameSuffix}";
            version = hls-orig.version;
            phases = ["installPhase"];
            nativeBuildInputs = with nixpkgs-stable; [
                installShellFiles makeWrapper
            ];
            installPhase = ''
                mkdir --parents "$out/bin"
                makeWrapper "${hls-orig}/bin/haskell-language-server" \
                    "$out/bin/haskell-language-server${exeSuffix}"
                for shell in fish zsh bash
                do
                    "$out/bin/${exeName}" --''${shell}-completion-script \
                        "$out/bin/${exeName}" > "${exeName}.$shell"
                    installShellCompletion --''${shell} "${exeName}.$shell"
                    rm "${exeName}.$shell"
                done
            '';
            meta = hls-orig.meta // meta;
        };

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

    hls = wrapHls "" "" {
        description = "Haskell Language Server (HLS) for GHC ${ghcVersion}";
        longDescription = longDesc ''
        This package provides the server executable compiled against GHC
        ${ghcVersion}.  It has the name original name of
        "haskell-language-server," which may clash with versions compiled for
        other compilers.
        '';
    };

    hls-renamed = wrapHls "-renamed" "-${ghcVersion}" {
        description =
            "Haskell Language Server (HLS) for GHC ${ghcVersion}, renamed binary";
        longDescription = longDesc ''
        This package provides the server executable compiled against GHC
        ${ghcVersion}.  The binary has been renamed from
        "haskell-language-server" to "haskell-language-server-${ghcVersion}" to
        allow Nix to install multiple versions to the same profile for those
        that wish to use the HLS wrapper.
        '';
    };

    hls-wrapper = build.haskell-language-server-wrapper.overrideAttrs (old: {
        name = "haskell-language-server-wrapper";
        meta = old.meta // {
            description = "Haskell Language Server (HLS) wrapper";
            longDescription = "This package provides the server wrapper.";
        };
    });

    hls-wrapper-nix = nixpkgs-stable.callPackage ./hls-wrapper-nix.nix {
        inherit hls-wrapper;
        nix-project-lib = nix-project.nix-project-lib;
    };

    direnv-nix-lorelei =
        (import external.direnv-nix-lorelei).direnv-nix-lorelei;

    stack = nixpkgs-unstable.stack;

    stack-args = args: (nixpkgs-stable.writeScriptBin "stack" ''
        #!${nixpkgs-stable.runtimeShell}
        exec "${stack}/bin/stack" ${args} "$@"
    '') // {
        name = "stack-args";
        version = stack.version;
        meta.description = "Haskell Stack with args: ${args}";
        meta.longDescription = ''
        This package provides a wrapper script around the Haskell Stack
        executable that tacks on `${args}` to every call.  This forces
        disablment of Nix across all platforms.
        '';
    };

    stack-nix = stack-args "--nix";
    stack-nonix = stack-args "--no-nix --system-ghc";

    stackNixPackages = stackYaml: pkgs:
        let
            jsonFile = nixpkgs-stable.runCommand "yaml2json" {} ''
                "${nixpkgs-stable.yj}/bin/yj" < ${stackYaml} > "$out"
            '';
            json = builtins.fromJSON (builtins.readFile jsonFile);
            packageNames = json.nix.packages;
            err = path: throw "package not found: ${path}";
            select = path:
                lib.attrByPath (lib.splitString "." path) (err path) pkgs;
        in builtins.map select packageNames;

    cabal-install = nixpkgs-unstable.cabal-install;
    direnv = nixpkgs-stable.direnv;
    ghc = nixpkgs-stable.haskell.compiler."${npGhc ghcVersion}"
        or nixpkgs-unstable.haskell.compiler."${npGhc ghcVersion}"
        or nixpkgs-stable.haskell.compiler."${npGhc ghcVersion}Binary"
        or nixpkgs-unstable.haskell.compiler."${npGhc ghcVersion}Binary"
        or nixpkgs-hn.haskell-nix.compiler."${hnGhc ghcVersion}";
    implicit-hie = nixpkgs-unstable.haskellPackages.implicit-hie;

    hls-full =
        let
            included = [
                cabal-install
                direnv
                direnv-nix-lorelei
                ghc
                hls-renamed
                hls-wrapper
                hls-wrapper-nix
                implicit-hie
                stack-nonix
            ];
            desc = p: "${p.name}:\n    ${p.meta.description}";
            allDesc = lib.strings.concatMapStringsSep "\n" desc included;
            name = "haskell-hls-nix-full";
            meta.description =
                "Haskell Language Server (HLS) full/easy installation";
            meta.longDescription = ''
        This is a package combines a few packages together to make for an easy
        single installation if you don't want to think about what you need.

        ${allDesc}
        '';
        in nixpkgs-stable.symlinkJoin {
            inherit name meta;
            paths = included;
        };

    distribution = {
        inherit
        cabal-install
        direnv
        direnv-nix-lorelei
        ghc
        hls
        hls-full
        hls-renamed
        hls-wrapper
        hls-wrapper-nix
        implicit-hie
        stack
        stack-args
        stack-nix
        stackNixPackages
        stack-nonix
        ;
    };

in {
    inherit
    build
    updateMaterialized
    distribution
    nix-project
    nixpkgs-stable;
}
