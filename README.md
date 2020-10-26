- [About this project](#sec-1)
- [About Haskell Language Server](#sec-2)
- [Using the project](#sec-3)
  - [Nix package manager setup](#sec-3-1)
  - [Cache setup](#sec-3-2)
  - [For Stack, installing HLS for multiple projects](#sec-3-3)
- [Prior Art](#sec-4)
  - [Projects that pre-date HLS](#sec-4-1)
  - [Other builds of HLS](#sec-4-2)
- [Release](#sec-5)
- [License](#sec-6)
- [Contribution](#sec-7)

[![img](https://github.com/shajra/nix-haskell-hls/workflows/CI/badge.svg)](https://github.com/shajra/nix-haskell-hls/actions)

# About this project<a id="sec-1"></a>

This project has a [Nix](https://nixos.org/nix) expression to build the [Haskell Language Server (HLS)](https://github.com/haskell/haskell-language-server) with [Haskell.nix](https://input-output-hk.github.io/haskell.nix/).

The Haskell Language Server is the latest attempt make an IDE-like experience for the [Haskell programming language](https://www.haskell.org). HLS implements [Microsoft's Language Server Protocol (LSP)](https://microsoft.github.io/language-server-protocol). With this approach, a background service is launched for a either a [Stack](https://docs.haskellstack.org/en/stable/README/) or [Cabal](https://cabal.readthedocs.io/en/latest/) project that answers questions needed by an editor for common IDE features (code navigation, completion, documentation, refactoring, etc.). There's a variety of editors supporting LSP that can take advantage of such a server.

The Nix expression provided by this project builds two versions of HLS

-   the latest release (0.5.1)
-   a recent version of the "master" branch.

Additionally, for each of these versions of HLS, there's a build against the following versions of GHC:

-   8.6.5
-   8.8.4
-   8.10.2

[This project's continuous integration (using GitHub Actions)](https://github.com/shajra/nix-haskell-hls/actions) caches all six of these builds at [Cachix](https://cachix.org/), a service for caching pre-built Nix packages. If you don't want to wait for a full local build when first using this project, setting up Cachix is recommended.

Note that not every commit of the HLS "master" branch is built and cached to Cachix, only versions referenced by the commits of this `nix-haskell-hls` project. Upgrading to the latest commit of HLS's "master" is done periodically, but still manually.

See [the provided documentation on Nix](doc/nix.md) for more on what Nix is, why we're motivated to use it, and how to get set up with it for this project.

# About Haskell Language Server<a id="sec-2"></a>

It's important to note that for each version of GHC you use on your projects, you need an instance of HLS compiled specifically for that version of GHC. If you have multiple instances of HLS installed in your path, then a provided wrapper can be used to select the right one for the version of GHC used by any given project.

Also, note that even though we might be able to install multiple instances of HLS into the same environment, it's generally difficult to install multiple versions of GHC into the same environment.

For instance, we can't install multiple versions of GHC into the same `nix-env` profile because both versions would have a conflict trying to install a binary called "ghc." We can, though, set up `nix-shell` for each of our projects such that each `nix-shell` invocation puts whatever version of GHC is needed onto our path within the shell. This is similar to how Stack manages different GHC versions by default.

See the official [HLS documentation](https://github.com/haskell/haskell-language-server) for details on HLS's operation and usage.

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

## For Stack, installing HLS for multiple projects<a id="sec-3-3"></a>

If using Stack, we can let Stack pull in the correct version of GHC needed by a project.

In our normal user `PATH` we can then install multiple instances of HLS (for which ever versions of GHC our projects happen to use). And we can also install the HLS wrapper to select the right version of HLS for any given project.

As discussed in [the provided documentation on Nix](doc/nix.md) we can see that this project's Nix expression provides three derivations:

```shell
nix show-derivation --file . > /dev/null
nix search --no-cache --file .
```

    * hls (haskell-language-server-ghc884)
      Haskell Language Server (HLS) for GHC 8.8.4
    
    * hls-renamed (haskell-language-server-ghc884-renamed)
      Haskell Language Server (HLS) for GHC 8.8.4, renamed binary
    
    * hls-wrapper (haskell-language-server-wrapper)
      Haskell Language Server (HLS) wrapper

To use the wrapper, ignore the `hls` derivation. It provides a binary named "haskell-language-server," but you can only have one of these on your environment's `PATH` at a time.

Instead, we'll install multiple versions of the `hls-renamed` derivation, which suffixes the binary's file name with the version number of GHC it was compiled for. This way we can install multiple versions of this `hls-renamed` package to our Nix profile.

In addition, we'll also need to install the `hls-wrapper`. Here we show installing the wrapper and a couple of HLS binaries targeting different versions of GHC:

```shell
nix-env --install --file . \
    --attr hls-renamed \
    --attr hls-wrapper
nix-env --install --file . \
    --argstr ghcVersion ghc8102 \
    --arg    unstable   true \
    --attr hls-renamed
```

Note how we use the `--argstr` switch to set `ghcVersion` to the version of GHC we want. These strings are the same identifiers used to identify versions of GHC within Nixpkgs. If you don't specify `ghcVersion`, a default is used (currently "ghc884").

Similarly, by default, we get the latest officially released version of HLS. But if we want a bleeding version from the "master" branch instead, we can use the `--arg` switch to set `unstable` to `true`, as we do for our 8.10.2-targeting instance of HLS above.

We took the wrapper from the default build for GHC 8.8.4, but it doesn't matter much which build the wrapper comes from. It's not doing much more than choosing another program to delegate to.

These packages have been installed in our Nix profile, which we can see by querying our profile witht `nix-env`:

```shell
nix-env --query
```

    haskell-language-server-ghc8102-renamed
    haskell-language-server-ghc884-renamed
    haskell-language-server-wrapper

If we've set up our Nix profile in our `PATH`, we should be able to see what we've installed as available:

```shell
for suffix in wrapper 8.10.2 8.8.4
do readlink -f "$(which "haskell-language-server-$suffix")"
done
```

    
    > /nix/store/wizfg7gf7malcigac5s4iaqm6jz3jfx5-haskell-language-server-wrapper/bin/haskell-language-server-wrapper
    /nix/store/lc038c58d3p8xrivvmq6arn30w2978r3-haskell-language-server-ghc8102-renamed/bin/haskell-language-server-8.10.2
    /nix/store/i863633rwz2p75cbfzjy2a8z7w52g7p1-haskell-language-server-ghc884-renamed/bin/haskell-language-server-8.8.4

To test that HLS is working, you can go into a Stack project, and run the wrapper with no arguments:

```shell
haskell-language-server-wrapper
```

    (haskell-language-server-wrapper) Version 0.5.1.0 x86_64 ghc-8.8.4
    Current directory: /home/tnks/src/shajra/nix-haskell-hls/example-stack
    Operating system: linux
    Arguments: []
    Cradle directory: /home/tnks/src/shajra/nix-haskell-hls/example-stack
    …
    Files that failed:
     * /home/tnks/src/shajra/nix-haskell-hls/example-stack/Setup.hs
    [INFO] finish: User TypeCheck (took 0.03s)
    
    Completed (3 files worked, 1 file failed)
    haskell-language-server-wrapper: callProcess: /home/tnks/src/shajra/nix-haskell-hls/nix-profile/bin/haskell-language-server-8.8.4 (exit 1): failed

You'll notice that most of the files check out successfully, but HLS has a problem with `Setup.hs` files. This is a [known problem](https://github.com/mpickering/hie-bios/issues/208).

# Prior Art<a id="sec-4"></a>

## Projects that pre-date HLS<a id="sec-4-1"></a>

Prior initiatives, [GHCIDE](https://github.com/haskell/ghcide) and [Haskell IDE Engine (HIE)](https://github.com/haskell/haskell-ide-engine), have joined forces behind HLS, so there's some expectation that HLS will subsume these projects in the future. Some people prefer to use GHCIDE directly just to get just the compiler feedback and not all of the other features HLS provides (like code formatting).

For both GHCIDE and HIE, there are respective projects maintaining Cachix-cached Nix builds/expressions. GHCIDE has [ghcide-nix](https://github.com/cachix/ghcide-nix) and HIE has [all-hies](https://github.com/Infinisil/all-hies). This project provides something similar for HLS.

## Other builds of HLS<a id="sec-4-2"></a>

HLS provides [officially released binaries](https://github.com/haskell/haskell-language-server/releases) for a variety of operating systems, but unfortunately, the binaries compiled for Linux don't work on NixOS due to assumptions when linking.

Problems like this are one reason to want a Nix expression for compilation. With a Nix expression, we have confidence our built artifact will work not only on NixOS, but any other operating system with Nix installed.

There's two ways to address this problem with Nix:

-   take the officially compiled binaries and patch them in a Nix expression
-   build HLS from scratch with a Nix expression.

Asad Saeeduddin does the former with his [all-hls](https://github.com/masaeedu/all-hls) project. One benefit of this approach is that we don't have to wait on anything to compile, relying instead on the official pre-built binaries. For most people, this is likely sufficient.

Additionally, Nixpkgs has a build of HLS as well. So with both `all-hls` and the build in Nixpkgs, we can get cached builds of HLS that are installable with Nix.

The main downside with using `all-hls` or the Nixpkgs build is the restriction to a specific build. If there's a new feature or fix in the latest "master" branch, we don't have a pre-built binary for use with `all-hls`. We can override the Nix expression in Nixpkgs, but this can be tricky to get compiling sometimes because Nixpkgs pins all Haskell dependencies to a curated set.

This is where this project's build with [Haskell.nix](https://input-output-hk.github.io/haskell.nix/) can help. Haskell.nix helps us get the precision of a Nix expression, but using a plan that is resolved by Cabal. Resolving dependencies is often contextual to a specific project. By only resolving the libraries needed for just HLS, we have a greater probability of not getting blocked by conflicts than the builds in Nixpkgs. Nixpkgs has the daunting task of getting the whole ecosystem to work with each library pinned to a specific version number.

# Release<a id="sec-5"></a>

The "master" branch of the repository on GitHub has the latest released version of this code. There is currently no commitment to either forward or backward compatibility.

"user/shajra" branches are personal branches that may be force-pushed to. The "master" branch should not experience force-pushes and is recommended for general use.

# License<a id="sec-6"></a>

All files in this "nix-haskell-hls" project are licensed under the terms of the MIT License.

Please see the [./COPYING.md](./COPYING.md) file for more details.

# Contribution<a id="sec-7"></a>

Feel free to file issues and submit pull requests with GitHub.

There is only one author to date, so the following copyright covers all files in this project:

Copyright © 2020 Sukant Hajra
