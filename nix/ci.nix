args@
{ ghcVersion
, hlsUnstable
, checkMaterialization ? true
}:

(import ./. args).distribution
