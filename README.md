- [About this project](#sec-1)
- [Prior Art](#sec-2)
- [Using the project](#sec-3)
  - [Nix package manager setup](#sec-3-1)
  - [Cache setup](#sec-3-2)
  - [Installing Haskell Language Server](#sec-3-3)
- [Release](#sec-4)
- [License](#sec-5)
- [Contribution](#sec-6)

[![img](https://github.com/shajra/nix-haskell-hls/workflows/CI/badge.svg)](https://github.com/shajra/nix-haskell-hls/actions)

# About this project<a id="sec-1"></a>

This project has a [Nix](https://nixos.org/nix) expression for the [Haskell Language Server (HLS)](https://github.com/haskell/haskell-language-server).

The Haskell Language Server is the latest attempt make an IDE-like experience for the [Haskell programming language](https://www.haskell.org). HLS implements [Microsoft's Language Server Protocol (LSP)](https://microsoft.github.io/language-server-protocol). With this approach, a background service is launched for a either a [Stack](https://docs.haskellstack.org/en/stable/README/) or [Cabal](https://cabal.readthedocs.io/en/latest/) project that answers questions needed by an editor for common IDE features (code navigation, completion, documentation, refactoring, etc.). There's a variety of editors supporting LSP that can take advantage of such a server.

The Nix expression provided by this project builds the latest version of HLS targeting a variety of GHC compilers. Additionally, [this project's continuous integration (using GitHub Actions)](https://github.com/shajra/nix-haskell-hls/actions) caches built packages at [Cachix](https://cachix.org/), a service for caching pre-built Nix packages. If you don't want to wait for a full local build when first using this project, setting up Cachix is recommended.

See [the provided documentation on Nix](doc/nix.md) for more on what Nix is, why we're motivated to use it, and how to get set up with it for this project.

# Prior Art<a id="sec-2"></a>

Prior initiatives to accomplish this, [GHCIDE](https://github.com/haskell/ghcide) and [Haskell IDE Engine (HIE)](https://github.com/haskell/haskell-ide-engine), have joined forces behind HLS, so there's some expectation that HLS will subsume these projects in the future.

For both GHCIDE and HIE, there are respective projects maintaining Cachix-cached Nix builds/expressions. GHCIDE has [ghcide-nix](https://github.com/cachix/ghcide-nix) and HIE has [all-hies](https://github.com/Infinisil/all-hies). This project provides something similar for HLS.

Note that you need a version of HLS compiled specifically for the GHC compiler used by your project. If you have multiple versions of GHC and HLS installed in your path, then a provided wrapper can be used to select the right one for the version of GHC used by your project. HLS personal laptops (one NixOS, another MacOS). Later on it may have packages for more machines. For now, the expression evaluates to an attribute set of package derivations. The package sets are different depending on the detected operating system.

# Using the project<a id="sec-3"></a>

## Nix package manager setup<a id="sec-3-1"></a>

> **<span class="underline">NOTE:</span>** You don't need this step if you're running NixOS, which comes with Nix baked in.

If you don't already have Nix, the official installation script should work on a variety of UNIX-like operating systems. The easiest way to run this installation script is to execute the following shell command as a user other than root:

```shell
curl https://nixos.org/nix/install | sh
```

This script will download a distribution-independent binary tarball containing Nix and its dependencies, and unpack it in `/nix`.

The Nix manual describes [other methods of installing Nix](https://nixos.org/nix/manual/#chap-installation) that may suit you more.

## Cache setup<a id="sec-3-2"></a>

It's recommended to configure Nix to use shajra.cachix.org as a Nix *substituter*. This project pushes built Nix packages to [Cachix](https://cachix.org/) as part of its continuous integration. Once configured, Nix will pull down these pre-built packages instead of building them locally.

You can configure shajra.cachix.org as a substituter with the following command:

```shell
nix run \
    --file https://cachix.org/api/v1/install \
    cachix \
    --command cachix use shajra
```

This will perform user-local configuration of Nix at `~/.config/nix/nix.conf`. This configuration will be available immediately, and any subsequent invocation of Nix commands will take advantage of the Cachix cache.

If you're running NixOS, you can configure Cachix globally by running the above command as a root user. The command will then configure `/etc/nixos/cachix/shajra.nix`, and will output instructions on how to tie this configuration into your NixOS configuration.

## Installing Haskell Language Server<a id="sec-3-3"></a>

TODO

# Release<a id="sec-4"></a>

The "master" branch of the repository on GitHub has the latest released version of this code. There is currently no commitment to either forward or backward compatibility.

"user/shajra" branches are personal branches that may be force-pushed to. The "master" branch should not experience force-pushes and is recommended for general use.

# License<a id="sec-5"></a>

All files in this "nix-haskell-hls" project are licensed under the terms of the MIT License.

Please see the [./COPYING.md](./COPYING.md) file for more details.

# Contribution<a id="sec-6"></a>

Feel free to file issues and submit pull requests with GitHub.

There is only one author to date, so the following copyright covers all files in this project:

Copyright © 2020 Sukant Hajra
