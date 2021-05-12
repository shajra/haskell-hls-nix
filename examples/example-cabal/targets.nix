{ pkgs ? []
}:

with (import <nixpkgs> {});
with (import ./build.nix);
with builtins;

let
    getOrDefault = xs: if pkgs == [] then xs else stdenv.lib.intersectLists pkgs xs;
    withPrefix = prefix: xs: map (x: prefix + "." + x) xs;
    writeTargetsFile = name: xs: writeText name (stdenv.lib.concatStrings (map (x: x + "\n") xs));

    projectPackages = getOrDefault (attrNames project);
    projectTargets = attrNames (stdenv.lib.filterAttrs (name: value: elem name projectPackages) project);
    projectTargetStrs = withPrefix "project" projectTargets;

    targetsFile = writeTargetsFile "targets" projectTargetStrs;
in { inherit targetsFile; }
