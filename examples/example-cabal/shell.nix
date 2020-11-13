# Select out a Nix derivation from the "build" Nix expression that specifies
# dependencies we need in our Nix shell to build our application.
#
(import ./build.nix).shell
