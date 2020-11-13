# Select out a Nix derivation from the "build" Nix expression for specifies the
# application we're building.
#
(import ./build.nix).project.example-haskell-app
