args@
{ config ? import ./config.nix
, ghcVersion ? config.ghcVersion
, hlsUnstable ? config.hls.unstable
}:

(import ./nix args).distribution
