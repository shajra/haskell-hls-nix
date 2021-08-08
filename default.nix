args@{ config ? import ./config.nix
, checkMaterialization ? config.haskell-nix.checkMaterialization
, nixpkgs-pin ? config.haskell-nix.nixpkgs-pin
, index-state ? config.haskell-nix.hackage.index.state
, index-sha256 ? config.haskell-nix.hackage.index.sha256
, ghcVersion ? config.ghcVersion
, hlsUnstable ? config.hls.unstable
}:

with (import ./nix args);

{
    inherit
    cabal-install
    direnv
    direnv-nix-lorelei
    ghc
    hls
    hls-renamed
    hls-wrapper
    hls-wrapper-nix
    implicit-hie
    stack
    stack-args
    stack-nix
    stackNixPackages
    stack-nonix
    recommended
    ;
}
