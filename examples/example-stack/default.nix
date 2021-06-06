let

    # Some constant configuration that's factored separately.
    #
    config = import ./config.nix;

    # For reproducibility we'll use this project's pinned Nixpkgs instead of
    # `(import <nixpkgs> {})`.  This way we get a specific version of Nixpkgs
    # instead of a version that happens to be in the environment's `NIX_PATH`.
    #
    sources = import ../../nix/sources;
    nixpkgs = (import sources.nixpkgs-unstable) {
        # We don't want user configuration affecting this build.  This is
        # recommended boilerplate when importing Nixpkgs.
        config   = {};  # to avoid picking up ~/.config/nixpkgs/config.nix
        overlays = [];  # to avoid picking up ~/.config/nixpkgs/overlays
    };

    # This is the build of HLS for this project.
    #
    hls = import ../.. {
        ghcVersion  = config.ghcVersion;
        hlsUnstable = config.hlsUnstable;
    };

# This builds all the executables provided by a Stack project and puts them
# into a single Nix package derivation.  We can use this not only to build with
# Nix, but also with `nix-shell` to get a shell environment with `PATH` set up
# with HLS, Stack, and GHC.  The GHC instance won't be loaded with packages of
# any dependencies.  Instead of Nix, Stack manage Haskell dependencies.
#
in nixpkgs.haskell.lib.buildStackProject {

    # This name is just for Nix metadata.
    name = "example-haskell-stack";

    # buildStackProject has explicit configuration for the GHC instance.
    #
    ghc = nixpkgs.haskell.compiler.${config.ghcVersion};

    # buildStackProject also has explicit configuration for the Stack instance.
    # To allow Stack invocations and HLS invocations to work within the
    # nix-shell this wrapper script disable's Stack's built-in Nix integration
    # forcibly (even if we're on NixOS).  Additionally we tell Stack not to
    # manage getting a GHC instance.  Nix sets up all needed build tools and
    # non-Haskell dependencies.
    #
    stack = hls.stack-nonix;

    # These are extra tools beyond GHC and Stack that we want on our PATH in our
    # Nix shell.
    #
    nativeBuildInputs = # nixpkgs.lib.optionals nixpkgs.lib.inNixShell [
    [
        hls.hls-renamed
        hls.hls-wrapper
        hls.implicit-hie
    ];

    # Here we specify non-Haskell dependencies.  They are not automatically
    # detected/guessed, and we must list them out explicitly.
    #
    # buildInputs = [nixpkgs.icu67];
    buildInputs = hls.stackNixPackages ./stack.yaml nixpkgs;

    # It's recommended to always filter source to just what's needed.  This way,
    # any intermediate files created while developing don't affect Nix hash
    # calculations, which could result in cache misses against /nix/store.
    #
    src = nixpkgs.lib.sourceFilesBySuffices ./.
        [".hs" ".lhs" ".cabal" ".yaml"];  #".lock"];

}
