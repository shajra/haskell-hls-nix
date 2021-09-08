- [About this project](#sec-1)
- [Do you need this project?](#sec-2)
- [Overview of using this project](#sec-3)
- [Dependency management](#sec-4)
  - [Types of dependencies](#sec-4-1)
  - [Avoiding Stack's built-in Nix integration](#sec-4-2)
- [Nix setup](#sec-5)
  - [Nix package manager setup](#sec-5-1)
  - [Cache setup](#sec-5-2)
- [This project's Nix expression](#sec-6)
- [User-level installation of tools with Nix](#sec-7)
  - [Recommended user-level installation](#sec-7-1)
  - [Limitations of a user-level installation](#sec-7-2)
  - [Example user-level installation](#sec-7-3)
- [Project-level Nix shells](#project-shell)
- [Editor integration with Nix shells](#sec-9)
  - [Enabling an editor for LSP](#sec-9-1)
  - [Integrating an LSP-enabled editor with Nix](#sec-9-2)
- [Workarounds for known problems](#sec-10)
  - [Regenerating a Nix shell environment when dependencies change](#sec-10-1)
  - [Explicit `hie.yaml` files](#sec-10-2)
- [Building with Nix](#sec-11)
- [Prior art](#prior-art)
  - [Non-Nix builds/distributions of HLS](#sec-12-1)
  - [Other Nix builds of HLS](#sec-12-2)
  - [Projects that pre-dated HLS](#sec-12-3)
- [Release](#sec-13)
- [License](#sec-14)
- [Contribution](#sec-15)

[![img](https://github.com/shajra/haskell-hls-nix/workflows/CI/badge.svg)](https://github.com/shajra/haskell-hls-nix/actions)

# About this project<a id="sec-1"></a>

This project has a [Nix](https://nixos.org/nix) expression to build the [Haskell Language Server (HLS)](https://github.com/haskell/haskell-language-server) with [Haskell.nix](https://input-output-hk.github.io/haskell.nix/).

The Haskell Language Server is the latest attempt to support an IDE experience for the [Haskell programming language](https://www.haskell.org). HLS implements [Microsoft's Language Server Protocol (LSP)](https://microsoft.github.io/language-server-protocol). With this approach, editors launch a background service for each [Stack](https://docs.haskellstack.org/en/stable/README/) or [Cabal](https://cabal.readthedocs.io/en/latest/) project that answers questions to support common IDE features (code navigation, completion, documentation, refactoring, etc.). There's a variety of editors supporting LSP that can take advantage of such a server.

Nix is a package manager we can use not only to build and install HLS, but also manage Haskell development environments. If you're new to Nix, see [the provided documentation on Nix](doc/nix.md) for more on what Nix is, why we're motivated to use it, and how to get set up with it for this project. A large draw to Nix is for a highly reproducible build that's portable across computers. Nix, though, is not required to use HLS.

The [Nix expression provided by this project](./default.nix) builds two versions of HLS

-   the latest release (1.3.0)
-   a recent commit from the "main" branch of HLS on GitHub.

To use HLS with a Haskell project, you must have an instance of HLS compiled with the same version of GHC used to compile your project. To meet the needs of different users, we build both versions of HLS listed above against all of the following versions of GHC:

-   8.6.5
-   8.8.4
-   8.10.6
-   8.10.7

These versions of GHC match what's [built, tested, and cached by the Haskell.nix project](https://input-output-hk.github.io/haskell.nix/reference/supported-ghc-versions/#supported-ghc-versions).

This project's continuous integration (using GitHub Actions)]] caches all eight of these builds at [Cachix](https://cachix.org/), a service for caching pre-built Nix packages. If you don't want to wait for a full local build when first using this project, setting up Cachix is recommended.

Note that not every commit of the HLS "main" branch is built and cached to Cachix, only versions referenced by the commits of this `haskell-hls-nix` project. Upgrading to the latest commit of HLS's "main" is done periodically, but still manually.

In addition to HLS, this project includes some useful Nix packages and functions for developing Haskell with Nix and HLS. Notably, we provide

-   an HLS Nix wrapper script that helps enter a Nix shell when running HLS
-   [Lorelei](https://github.com/shajra/direnv-nix-lorelei), a script to help integrate [Direnv](https://direnv.net/) with Nix projects.

# Do you need this project?<a id="sec-2"></a>

Before you start just using this project, it's good to make sure you're aware of some your choices.

If you're not on NixOS, there are simple ways of getting HLS without Nix. Even if you're committed to using Nix, there are other ways of getting HLS with Nix. All of these methods are discussed in a later section on [prior art](#prior-art).

What this project offers more uniquely is a build with [Haskell.nix](https://input-output-hk.github.io/haskell.nix/). For users of this project, the fact it uses Haskell.nix may be a hidden implementation detail. However, this approach to building HLS offers the maintainers an easier way to consistently build any version of HLS with Nix, including recent commits from the upstream "main" branch. This way, we can more easily get the latest versions of dependencies and HLS itself, to get more recent fixes and features.

However, even if you don't use this project at all, you may find its documentation useful for navigating how to use HLS with Nix. This documentation is as much about a Nix integration of Haskell projects as it is setting up HLS with Nix. We introduce Nix and HLS, but you should have some prior familiarity with the Haskell language and tools like Cabal and Stack.

Nix has a reputation of complexity, but a good share of that reputation has been due to a lack of documentation that the Nix community has been working hard to fill. The documentation of this project is a step towards bridging that gap, so that more tools are accessible when we need them.

# Overview of using this project<a id="sec-3"></a>

At a high-level, the following four steps help us use HLS with Nix:

1.  installing development tools to the user environment's `PATH`
2.  if needed, writing *Nix expressions* for per-project configuration
3.  configuring editors to call HLS in our projects
4.  optionally, setting up projects with a Nix build.

To facilitate IDE-like features, editors need to invoke HLS with the `--lsp` switch, which starts HLS as a background process. Editors then continue to query this running service. We'll have a separate HLS process for each project we have open.

A project's process of HLS needs to have an environment with all dependencies correctly set up. This includes having a `PATH` set up with tools we'll need like Cabal or Stack, but also includes dependencies like C libraries needed for FFI binding.

To test the environment we've set up, we can run HLS with no arguments from a project's root directory. It should exit successfully with no concerning errors.

Nix offers us two ways to install tools and dependencies, including HLS:

-   We can use `nix-env` to install tools to a user-level environment.
-   We can use `nix-shell` to manage a project-level environment.

`nix-env` is a lot like other package managers like APT, RPM, or Homebrew. One important difference is that `nix-env` installs packages to `~/.nix-profile` and not other system locations like `/usr` or `/usr/local`. So Nix users typically add `~/.nix-profile/bin` to their environment's `PATH`. With `nix-env` we can install tools like HLS, GHC, Cabal, Stack, and others. We recommend installing what's needed for editors to call HLS successfully in the common case.

There are some Haskell projects that will need different tools and libraries than we install at a system- or user-level. For instance, two projects may depend on conflicting versions of a dependency. The user's normal environment can only provide one of these projects what it needs.

In these instances we can use `nix-shell` to create a project-specific environment. We can author a Nix expression in a file called `shell.nix` in our project's root directory. Then when we execute `nix-shell` from the project's root, we enter a Bash shell with environment variables set up for the project, including `PATH`. The shell's environment can provide different versions of tools and libraries we need so that HLS, Cabal, Stack, and other tools can be called as we would expect. Commands in a Nix shell can be called both in an interactive Bash session, as well as non-interactively (one-off) with `nix-shell`'s `--run` switch.

We'll also have to configure our editors to invoke HLS, dealing with the possibility that it might be called within a Nix shell. The provided drop-in replacement HLS Nix wrapper script can help with that. Alternatively, we can use Direnv and Lorelei.

Finally, though optional, for each project you may want to author not only a Nix expression for `nix-shell`, but also another expression to allow building the project with `nix build`. Though Cabal and Stack have come a long way, Nix builds have uniquely strong architectural properties. Not only are they highly reproducible and portable, but you can have confidence that the build of one project won't inadvertently affect the build of another. All Nix builds are isolated and independent. Also, Nix expressions can compose with one another to make new Nix expressions. So having a Nix expression for our projects can facilitate its use as a dependency for another project built by Nix. An example of this is how your project-level Nix expressions can reference the HLS packages provided by this project's Nix expression, benefiting from the fact that we've already built HLS in GitHub and cached it in Cachix.

Later sections below dive deeper into the four steps listed above. Additionally, there are both a [Cabal example project](./examples/example-cabal) as well as a [Stack example project](./examples/example-stack) illustrating these steps.

# Dependency management<a id="sec-4"></a>

## Types of dependencies<a id="sec-4-1"></a>

What we need to set up for any given project to use HLS falls into three main categories:

-   executable tools (HLS, GHC, Cabal, Stack, etc.)
-   Haskell library dependencies (such as `mtl`, and `aeson`)
-   non-Haskell library dependencies (such as C libraries for FFI compilation)

Here's a quick summary of what Nix can manage or not, depending on whether your project builds with Stack or Cabal:

| Dependency Type       | Stack              | Cabal          |
|--------------------- |------------------ |-------------- |
| Executables           | Nix-manageable     | Nix-manageable |
| Haskell libraries     | Not Nix-manageable | Nix-manageable |
| Non-Haskell libraries | Nix-manageable     | Nix-manageable |

As you can see, we can manage all our dependencies with Nix, with one exception. Stack prevents Nix from easily managing Haskell dependencies, but does allow us to use Nix to manage executable tools and non-Haskell library dependencies. So for example, we can use Nix to pin down Stack, HLS, and C libraries, but Stack would managing pulling down and compiling Haskell libraries like `aeson` from Hackage.

We can choose the degree that we use Nix to set up our projects for use with HLS. We can use Nix to just install tools, or we can use Nix to manage everything (with the exception of Stack's management of Haskell dependencies).

## Avoiding Stack's built-in Nix integration<a id="sec-4-2"></a>

Though we discourage its use, Stack provides some [built-in Nix integration](https://docs.haskellstack.org/en/stable/nix_integration/). This built-in integration calls `nix-shell` on the user's behalf internally, so users don't need to worry about setting up a `shell.nix` file or calling `nix-shell`. The motivations for discouraging the use of this Nix integration are discussed in a [separate document](./doc/stack-nix.md).

Instead, this project provides two alternatives to assist with Nix integration:

-   an HLS Nix wrapper script that helps enter a Nix shell when running HLS.
-   [Lorelei](https://github.com/shajra/direnv-nix-lorelei), a script to accomplish a similar result, but using [Direnv](https://direnv.net/).

The HLS Nix wrapper script is easy to use. Lorelei can be faster and more configurable, though a few more steps to set up. If you use Lorelei, you won't need the HLS Nix wrapper script.

# Nix setup<a id="sec-5"></a>

To use Nix at all, you first need to have it on your system.

## Nix package manager setup<a id="sec-5-1"></a>

> **<span class="underline">NOTE:</span>** You don't need this step if you're running NixOS, which comes with Nix baked in.

If you don't already have Nix, [the official installation script](https://nixos.org/learn.html) should work on a variety of UNIX-like operating systems:

```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```

If you're on a recent release of MacOS, you will need an extra switch:

```bash
sh <(curl -L https://nixos.org/nix/install) --daemon \
    --darwin-use-unencrypted-nix-store-volume
```

After installation, you may have to exit your terminal session and log back in to have environment variables configured to put Nix executables on your `PATH`.

The `--daemon` switch installs Nix in the recommended multi-user mode. This requires the script to run commands with `sudo`. The script fairly verbosely reports everything it does and touches. If you later want to uninstall Nix, you can run the installation script again, and it will tell you what to do to get back to a clean state.

The Nix manual describes [other methods of installing Nix](https://nixos.org/nix/manual/#chap-installation) that may suit you more.

## Cache setup<a id="sec-5-2"></a>

It's recommended to configure Nix to use shajra.cachix.org as a Nix *substitutor*. This project pushes built Nix packages to [Cachix](https://cachix.org/) as part of its continuous integration. Once configured, Nix will pull down these pre-built packages instead of building them locally (potentially saving a lot of time). This augments the default substitutor that pulls from cache.nixos.org.

You can configure shajra.cachix.org as a substitutor with the following command:

```sh
nix run \
    --file https://cachix.org/api/v1/install \
    cachix \
    --command cachix use shajra
```

Cachix is a service that anyone can use. You can call this command later to add substitutors for someone else using Cachix, replacing "shajra" with their cache's name.

If you've just run a multi-user Nix installation and are not yet a trusted user in `/etc/nix/nix.conf`, this command may not work. But it will report back some options to proceed.

One option sets you up as a trusted user, and installs Cachix configuration for Nix locally at `~/.config/nix/nix.conf`. This configuration will be available immediately, and any subsequent invocation of Nix commands will take advantage of the Cachix cache.

You can alternatively configure Cachix as a substitutor globally by running the above command as a root user (say with `sudo`), which sets up Cachix directly in `/etc/nix/nix.conf`. The invocation may give further instructions upon completion.

# This project's Nix expression<a id="sec-6"></a>

The [Nix expression provided by this project](./default.nix) evaluates to a function that outputs an *attribute set* of *package derivations*. This function has some default arguments that can be explicitly overridden. Nix CLI tools like `nix` and `nix-env` allow us do to this overriding with the `--argstr` and `--arg` switches.

For this project's Nix expression, the following overrides can be done:

-   `--argstr ghcVersion ${GHC_VERSION}` sets the GHC version used for the build (the default is otherwise `8.10.6`).
-   `--arg hlsUnstable ${BOOLEAN_VALUE}` when set to `true` picks a recent commit from the "main" branch for the HLS packages (defaulting otherwise to `false`, which selects the 1.3.0 release of HLS).

We can see the package derivations provided with the following `nix` calls:

```sh
nix show-derivation --file . >/dev/null 2>&1
nix search --no-cache --file .
```

    * cabal-install (cabal-install)
      The command-line interface for Cabal and Hackage
    
    * direnv (direnv)
      A shell extension that manages your environment
    
    * direnv-nix-lorelei (direnv-nix-lorelei)
      Alternative Nix functions for Direnv
    
    * ghc (ghc)
      The Glasgow Haskell Compiler
    
    * hls (haskell-language-server-ghc8106)
      Haskell Language Server (HLS) for GHC 8.10.6
    
    * hls-full (haskell-hls-nix-full)
      Haskell Language Server (HLS) full/easy installation
    
    * hls-renamed (haskell-language-server-ghc8106-renamed)
      Haskell Language Server (HLS) for GHC 8.10.6, renamed binary
    
    * hls-wrapper (haskell-language-server-wrapper)
      Haskell Language Server (HLS) wrapper
    
    * hls-wrapper-nix (hls-wrapper-nix)
      Haskell Language Server (HLS) wrapper for Nix
    
    * implicit-hie (implicit-hie)
      Auto generate hie-bios cradles & hie.yaml
    
    * stack (stack)
      The Haskell Tool Stack
    
    * stack-nix (stack-args)
      Haskell Stack with args: --nix
    
    * stack-nonix (stack-args)
      Haskell Stack with args: --no-nix --system-ghc

Note, when loading a directory with `--file`, a Nix expression is assumed to be in the directory's `default.nix` file. Also, the call of `nix show-derivation` is only needed one time to get search results as discussed in the provided documentation on Nix]].

The search results of `nix search` tell us the *attribute paths* we can use to select out the package derivations from our Nix expression. Above we got the default 1.3.0 version of HLS packages compiled for GHC 8.10.6. We could have explicitly called `nix search` above with `--argstr ghcVersion 8.10.6` and `--arg hlsUnstable false` and have gotten the same default results.

The `hls` package is provided for completeness, but its usage is not generally recommended. It provides the unmodified output of the upstream HLS project, specifically a binary named "haskell-language-server". You can only install one of these to your `PATH`. Because the version of GHC we compile HLS against must match the version of GHC for the project we wish to use HLS with, using `hls` would limit all of our projects to just one version of GHC. The `hls-renamed`, `hls-wrapper`, and `hls-wrapper-nix` packages help work around this limitation, and are recommended.

To install multiple instances of HLS to your `PATH`, use the `hls-renamed` attribute path. This suffixes the provided binary's filename with the version of GHC the instance of HLS has been compiled with. For example, when compiled with GHC 8.10.6, the binary is named "haskell-language-server-8.10.6".

The `hls-wrapper` attribute path provides the upstream HLS wrapper binary named "haskell-language-server-wrapper". When the wrapper is run in a root directory of a Haskell project, it detects which GHC version is needed by the project, and scans the `PATH` to call the instance of the renamed HLS binary compiled for the version of GHC needed by the project. It doesn't really matter which version of GHC you compile the wrapper itself against (`--argstr ghcVersion`). It's just a thin wrapper that is not GHC-sensitive.

The `hls-wrapper-nix` attribute path provides a wrapper of `hls-wrapper` that additionally helps enter a Nix shell.

As a convenience, this project provides a way to get some tools to assist building with HLS, specifically `cabal-install`, `ghc`, `stack`, `stack-nix`, `stack-nonix`, `implicit-hie`, `direnv`, and `direnv-nix-lorelei`. The `--arg hlsUnstable` has no relevance to or impact on any of these packages. With the exception of `ghc`, `--argstr ghcVersion` has no impact on these either. Many of these derivations are just passed through from [Nixpkgs](https://github.com/NixOS/nixpkgs).

`ghc` provides GHC at a version that is specified with `argstr ghcVersion`.

As you may guess, `cabal` and `stack` provide packages whose derivations for Cabal and Stack, respectively. `stack-nix` and `stack-nonix` are small shell wrappers around the `stack` executable that forcibly inject `--nix` and `--no-nix --system-ghc` switches, respectively, on each invocation.

The `implicit-hie` attribute provides a executable named `gen-hie`, which ideally you shouldn't need, but may be helpful in some circumstances when using HLS.

And lastly, the `direnv` and `direnv-nix-lorelei` attribute paths provide the [Direnv](https://direnv.net/) package and [Lorelei](https://github.com/shajra/direnv-nix-lorelei), a Nix plugin for it. We can use these together to integrate our editor with `nix-shell` as an alternative to `hls-wrapper-nix`.

# User-level installation of tools with Nix<a id="sec-7"></a>

## Recommended user-level installation<a id="sec-7-1"></a>

As noted before, to use HLS with a Haskell project, you must have an instance of HLS compiled with the same version of GHC as that project. It can be nice to install the following into a user-level `PATH`:

-   a recent version of GHC (as a default for Cabal-built projects)
-   multiple HLS instances targeting any GHC versions our projects may need, whether Stack- or Cabal-based.
-   an HLS wrapper to choose the right instance of HLS.
-   useful build tools like `cabal`, `stack`, and `gen-hie`
-   useful tools for editor/shell integration like `direnv` and `direnv-nix-lorelei`

By default, Stack downloads and manages its own instances of GHC, based on the version specified in each project's `stack.yaml` file. So by default, Stack won't use externally Nix-installed GHC instances, though you have the option of using Stack's `--system-ghc` switch to use the externally provided instance of GHC. When not using project-level Nix shells, letting Stack manage its own instances of GHC is convenient because it can choose the right version for any given project. However, the way Stack downloads GHC in NixOS is not reproducible or portable in a principled way]].

Stack may manage its own instance of GHC, but we still need to provide an instance of HLS for any versions of GHC our Stack projects use, same as for our Cabal projects.

Cabal does not manage its own instances of GHC, and just uses the version it finds on the environment's `PATH`. Often times a recent version of GHC is good enough for Cabal, which is why we recommend including one as part of a user-level installation.

With only tools installed in the user-level environment, both Cabal and Stack will manage Haskell dependencies, downloading them from Hackage and compiling them as part of the local build.

## Limitations of a user-level installation<a id="sec-7-2"></a>

The recommended user-level installation is a nice default to get HLS working, but won't work for all projects. Here's a few cases that need something further:

-   Cabal projects that need another version of GHC than installed at the user-level.

-   Cabal or Stack projects that depend on non-Haskell libraries that may not be available on the system.

One approach to deal with these problems uses a project-level Nix shell and is discussed in a [later section](#project-shell).

## Example user-level installation<a id="sec-7-3"></a>

To install programs into the user-level `PATH` with Nix, we generally use `nix-env`. When installing programs with `nix-env` we typically have `~/.nix-profile/bin` in our environment's `PATH`. `~/.nix-profile` is a symlink that points to our *active profile*, and calls to `nix-env` install to this location.

To illustrate installing with `nix-env` let's consider installing the following:

-   this project's drop-in replacement for the HLS wrapper
-   the latest release of HLS (1.3.0) targeting 8.10.6
-   useful recent stable versions of Cabal, Stack, `gen-hie`, Direnv, and Lorelei
-   GHC 8.10.6
-   a recent "main" branch version of HLS targeting GHC 8.8.4.

We can install the first four in one step relying on defaults of the Nix expression:

```sh
nix-env --install --file . \
    --attr hls-renamed \
    --attr hls-wrapper-nix \
    --attr cabal-install \
    --attr stack \
    --attr implicit-hie \
    --attr direnv \
    --attr direnv-nix-lorelei \
    --attr ghc
```

Note, because we want multiple instances of HLS on our `PATH` we use `hls-renamed` instead of `hls`.

Next we can install an instance of HLS targeting an alternate version of GHC (8.8.4) using `--argstr ghcVersion`, and with `--arg hlsUnstable` we can select a recent "main" branch version of HLS:

```sh
nix-env --install --file . \
    --argstr ghcVersion 8.8.4 \
    --arg hlsUnstable true \
    --attr hls-renamed
```

These packages have been installed in our Nix profile, which we can see by querying our profile with `nix-env`:

```sh
nix-env --query
```

    cabal-install-3.4.0.0
    direnv-2.28.0
    direnv-nix-lorelei
    ghc-8.10.6
    haskell-language-server-ghc8106-renamed
    haskell-language-server-ghc884-renamed
    hls-wrapper-nix
    implicit-hie-0.1.2.6
    stack-2.7.3

If we've set up the `bin` directory of our Nix profile in our `PATH`, we should be able to see what we've installed as available. For instance, we should be able to the see the version of GHC is as expected:

```sh
ghc --version
```

    The Glorious Glasgow Haskell Compilation System, version 8.10.6

Without using `nix-shell`, Cabal and Stack will both manage Haskell dependencies of projects. In this case, for Cabal you need to at least once call `cabal update` to download the latest index of Haskell packages on Hackage:

```sh
cabal update
```

For Stack, you don't have to explicitly call anything to get an index of Haskell packages.

# Project-level Nix shells<a id="project-shell"></a>

Sometimes we can't address all of our projects with one user-level environment. For instance, what do we do if two projects depend on conflicting versions of a non-Haskell dependency?

In these cases, we can use `nix-shell` to enter a Bash shell environment with environment variables tailored for the project. This gives us full control to specify all our dependencies per-project, including non-Haskell libraries (like C libraries needed for FFI binding).

Nix shells are configured in the Nix expression language saved in files with a ".nix" filename extension. To learn more about the language itself, we recommend

-   the official Nix manual's [chapter on the Nix language](https://nixos.org/manual/nix/stable/#ch-expression-language)
-   a [tutorial on the Nix language](https://github.com/shajra/example-nix/tree/master/tutorials/0-nix-intro#the-nix-language).

To learn more about writing Nix expressions for Cabal and Stack projects, see the [Nixpkgs guide on configuring Haskell packages](https://haskell4nix.readthedocs.io/).

Authoring a Nix expression isn't a lot of code, but it's not as simple as one line, so this project provides some examples to help follow along. We have one for Cabal]], and [another for Stack](./examples/example-stack). The Nix expressions in these examples include generous inline comments for guidance. We'll use these examples to illustrate some steps.

The code between these two examples is largely the same, and both have a dependency on the ICU C library for Unicode support, so these projects may likely not compile outside a Nix shell with Cabal or Stack alone (unless you happened to have installed globally the ICU library and header files).

Once you have a project-level Nix expression written should you should be able to

-   enter an interactive Nix shell by calling `nix-shell`
-   within the shell call `cabal` or `stack` as you normally would to build locally (for instance, `cabal build all` or `stack build`) with all needed dependencies set up in environment variables
-   call `haskell-language-server-wrapper`, which editors will need to call with the `--lsp` switch.

We can enter a project-tailored Nix shell by calling `nix-shell` with no arguments in the root directory of a Haskell project that has either a `shell.nix` or `default.nix` file. By default, `nix-shell` chooses `shell.nix` first.

Generally, `default.nix` is used for building Nix packages for a project. And `shell.nix` is used for creating a development environment for a project. This is the case for the Cabal-based example project. But sometimes `default.nix` is usable for both, which is illustrated in the Stack-based example project.

If you want to run commands within the shell non-interactively, we can use the `--run` switch. For example, we can build and run our project locally with Cabal (the example projects both print out a silly message):

```sh
cd examples/example-cabal
nix-shell --pure --run 'cabal run all'
```

    Resolving dependencies...
    Build profile: -w ghc-8.10.6 -O1
    In order, the following will be built (use -v for more details):
    …
    Answer to the Ultimate Question of Life,
        the Universe, and Everything: 42

The `--pure` flag clears out the users current environment before building out a new one for the Nix shell. This means anything anything on your path currently won't be available within the shell.

A similar `nix-shell` call will build our example Stack project within a Nix shell:

```sh
cd examples/example-stack
nix-shell --pure --run 'stack run'
```

    Answer to the Ultimate Question of Life,
        the Universe, and Everything: 42

If our project builds, we can test that HLS runs correctly, which we can do by calling HLS with no arguments. It should exit successfully reporting no failures. Here's an illustration of a successful run in our Cabal example project.

```sh
cd examples/example-cabal
nix-shell --pure --run 'haskell-language-server-wrapper' 2>&1
```

    trace: WARNING: 8.10.6 is out of date, consider using 8.10.7.
    warning: file 'nixpkgs' was not found in the Nix search path (add it using $NIX_PATH or -I), at (string):1:9; will use bash from your environment
    Found "/home/tnks/src/shajra/haskell-hls-nix/examples/example-cabal/hie.yaml" for "/home/tnks/src/shajra/haskell-hls-nix/examples/example-cabal/a"
    …
    
    Completed (5 files worked, 0 files failed)

The same command can test HLS working with our Stack example project:

```sh
cd examples/example-stack
nix-shell --pure --run 'haskell-language-server-wrapper' 2>&1
```

    trace: WARNING: 8.10.6 is out of date, consider using 8.10.7.
    warning: file 'nixpkgs' was not found in the Nix search path (add it using $NIX_PATH or -I), at (string):1:9; will use bash from your environment
    No 'hie.yaml' found. Try to discover the project type!
    …
    Completed (3 files worked, 0 files failed)
    2021-09-08 14:05:20.373964008 [ThreadId 642] INFO hls:	finish: GenerateCore (took 0.00s)

# Editor integration with Nix shells<a id="sec-9"></a>

## Enabling an editor for LSP<a id="sec-9-1"></a>

Having tools installed, or projects configured with Nix shells doesn't help us until we have an editor that can take advantage of this installation and configuration.

There are many editors that can support LSP. A lot of editors don't come with LSP support by default, but can be extended with plugins to get the LSP support we need to use HSL.

The [official HSL documentation on editor configuration](https://github.com/haskell/haskell-language-server#configuring-your-editor) has a few sections that cover configuration of many popular editors with both LSP support as well as hooking them up to call `haskell-language-server-wrapper`.

This works for projects that don't don't require entry into a Nix shell to pick up project-specific dependencies. To deal with projects that require entry into a Nix shell, we need to perform a few more steps discussed in the next section.

Ideally, we want the same editor configuration to load HLS on all Haskell projects, whether they require an environment provided by a Nix shell or not.

## Integrating an LSP-enabled editor with Nix<a id="sec-9-2"></a>

Our editors need to call HLS, but to get better control of dependencies, some of our projects may need to have HLS invoked in an environment provided by a Nix shell. HLS needs to run in an environment with all the project's dependencies accessible.

Most editors with support for the Language Server Protocol (LSP) have a configuration parameter to specify which executable to call to run HLS for a project. If you used the upstream-recommended `haskell-language-server-wrapper`, then HLS would start, but not with the environment provided by a project's Nix shell.

To deal with these problems, we offer two ways to integrate Nix with your editors so you can run HLS in the right environment, whether or not a Nix shell is needed to provide it.

Both of these methods are detailed in separate documents:

-   a [simple configuration with this project's HLS Nix wrapper `hls-wrapper-nix`](./doc/hls-wrapper-nix.md)
-   a [more complex configuration using Direnv and Lorelei](./doc/direnv.md) that can be faster in some instances.
    
    We recommend starting with the HLS Nix wrapper, and consider Direnv and Lorelei if you notice the Nix shell taking a long and annoying time to enter.
    
    Using the Nix wrapper can be as simple as just specifying `hls-wrapper-nix` instead of `haskell-language-server-wrapper` for your editor's LSP configuration.

# Workarounds for known problems<a id="sec-10"></a>

## Regenerating a Nix shell environment when dependencies change<a id="sec-10-1"></a>

When using a Nix shell for Cabal projects, the Nix shell typically provides all build tools, all Haskell libraries, and also all non-Haskell libraries. The example Cabal project illustrates a Nix expression providing all of these dependencies.

When we do this, our Nix shell is configured with a GHC with a builtin package database preloaded with the transitive closure of all Haskell dependencies needed by a project, but excluding packages of the project itself. Because the third-party libraries are prebuilt upon entry into the Nix shell, Cabal doesn't need to download anything from Hackage. In fact, we don't even need to call `cabal update` to retrieve the package index from Hackage when we set up a Nix shell this way.

As mentioned earlier, Stack does not easily allow Nix to manage Haskell dependencies, so the Nix expressions we use for Stack are different, and the GHC instance we get in our Nix shell won't be preloaded with any Haskell dependencies.

We can see the difference in the GHC instances of our example projects. Both the Cabal and Stack projects depend on the Haskell `text-icu` package. With the Cabal project we can see this package included with GHC:

```sh
cd examples/example-cabal
nix-shell --pure --run 'ghc-pkg list text-icu'
```

    /nix/store/rsyvws8dwv47h87mgm57spzvj4gnfq5n-ghc-8.10.6-with-packages/lib/ghc-8.10.6/package.conf.d
        text-icu-0.7.1.0

We can similarly look at the GHC instance for the Stack example project to see that it doesn't provide third-party Haskell dependencies:

```sh
cd examples/example-stack
nix-shell --pure --run 'ghc-pkg list text-icu'
```

    /nix/store/xygkar338ssrwqjcpmmbv1pkkpqc1yfy-ghc-8.10.6/lib/ghc-8.10.6/package.conf.d
        (no packages)

This leads to a complication with Cabal projects when using Nix. Changing the dependencies of a Cabal file mean we need to rebuild the package database that our project's Nix shell provides.

We'll need to enter a new Nix shell to get a new environment with our rebuilt the package database. We'll also need to restart the HLS instance process in our editor to pick up this new database from the new environment.

The problem described above applies specifically to Cabal-based projects that use a Nix shell. Unfortunately, there's a few known issues of [HLS not responding dynamically to changing dependencies](https://github.com/haskell/ghcide/issues/633). So when dependencies change, we may find we have to restart the HLS instance for the project, even with Stack-based projects.

This need to reenter Nix shell and restart HLS is inconvenient. Hopefully it can be addressed with future development. Fortunately, changing packages dependencies is not too common when developing a program.

Whatever editor you use, we recommend getting to know how to restart HLS for any project you have open.

## Explicit `hie.yaml` files<a id="sec-10-2"></a>

Each editor will have a way of determining where a project's root is. Some may have the users specify roots for each project. Others may make assumptions based on the location of source control directories, `cabal.project` files, or `stack.yaml` files.

From a root location, HLS will determine all the packages built for the project, as well as how they are built (Cabal, Stack, etc.). This determination is typically done implicitly. However, there are some needs that are not met with this implicit detection. When you encounter such a need you may have to generate a `hie.yaml` file and place it at the project's root. HIE stands for Haskell IDE Engine, a predecessor of HLS.

The `implicit-hie` package provides the `gen-hie` executable that we can run at a project's root to generate the implicit HIE configuration inferred by HLS. Just run `gen-hie` with no arguments at the root of your project and redirect the standard output to a `hie.yaml` file:

```sh
gen-hie > hie.yaml
```

This gives you a starting point in case the implicit HIE configuration is insufficient. If the implicit HIE configuration isn't causing you a problem, there's no benefit to explicitly specifying one. In fact, an explicit `hie.yaml` is somewhat a liability, because we have to keep it up-to-date with changes to our project structure.

The [`hie-bios` project](https://github.com/mpickering/hie-bios) documents the syntax of `hie.yaml` and all the features it supports.

One example of something you may put in an explicit `hie.yaml` file is an alternate Stack YAML file for HLS to use instead of the default `stack.yaml`.

Another problem we might encounter is that `Setup.hs` files are not handled correctly by HLS. This is a [known problem](https://github.com/mpickering/hie-bios/issues/208). `Setup.hs` files are used by Cabal projects to set up a project for development. They aren't though used by Stack projects. In many simple Cabal projects, they aren't needed at all, and can be deleted.

To illustrate this, the Cabal example project has `Setup.hs` files, but also has a hand-curated explicit `hie.yaml` file that sets up these `Setup.hs` files for HLS. If we removed this explicit `hie.yaml` file, we'd get errors for these files. However, this isn't so bad, because HLS could continue to work for the rest of the Haskell files in the project. Most Cabal projects have no noteworthy code in `Setup.hs` files.

# Building with Nix<a id="sec-11"></a>

When we run HLS, we are only using Nix to manage tools and dependencies needed for compilation. This is good for iterative development of a Haskell project. Local building happens in typical directories local to the project (specifically, `.stack-work` for Stack and `dist-newstyle` for Cabal)

We can, though, have Nix build our final application. Cabal and Stack have gone through great degrees of improvements to be more Nix-like, but Nix was built from the ground up to give us highly reproducible builds. When we build an application with Nix, this build ends up in `/nix/store`. Furthermore, all intermediate steps of the build are performed in a heavily isolated environment that limits filesystem and network access.

Both the example Cabal and Stack projects provide `default.nix` files that enable us to build these project with Nix using subcommands of the `nix` command-line tool, specifically `nix build`. If you're new to Nix, see [the provided documentation on Nix](doc/nix.md) for more about using `nix build`, `nix run`, and other commands.

When going through the Nix expressions in the example projects, notice how the Nix expressions we use for Nix shells shares common code with Nix expressions we use for building with `nix build`. This is often the case.

For the Stack example project, we use literally the same code in `default.nix` file for both building as well as specifying dependencies for a Nix shell. The Cabal example project has common Nix expressions are in `build.nix`, which support the `default.nix` file for building as well as the `shell.nix` file used for the project's Nix shell.

Since both of these projects have a dependency on the ICU C library, there's a good chance you don't have it installed in your system such that Cabal or Stack can find it. `cabal build` and `stack build` would fail not finding the necessary library. If we want to use normal `cabal` or `stack` calls, we'll need to do that in `nix-shell` as discussed in a [previous section](#project-shell).

But because our projects have Nix expressions for building, we can build and run them with Nix irrespective of the state of our user environment. Here's a run of our example Cabal project:

```sh
nix run \
    --file examples/example-cabal \
    --command example-haskell
```

    Answer to the Ultimate Question of Life,
        the Universe, and Everything: 42

Building and running Stack projects within Nix involve a relaxation to Nix's default sandboxing, but otherwise runs similarly:

```sh
nix run \
    --option sandbox relaxed \
    --file examples/example-stack \
    --command example-haskell
```

    Answer to the Ultimate Question of Life,
        the Universe, and Everything: 42

# Prior art<a id="prior-art"></a>

## Non-Nix builds/distributions of HLS<a id="sec-12-1"></a>

There are definitely more simple instructions for getting set up with HLS without Nix. Nix may have more complexity, but this is a tradeoff for the degree of reproducible and portable builds Nix gives us. Furthermore, NixOS users may have no choice but to install with Nix due to incompatibility with non-Nix methods.

Two primary methods of getting HLS are with

-   [officially released binaries](https://github.com/haskell/haskell-language-server/releases)
-   [Ghcup](https://www.haskell.org/ghcup/).

Ghcup can install more than HLS, including GHC and Cabal.

Unfortunately, all of these methods download precompiled binaries that make assumptions of dynamic linking incompatible with NixOS. NixOS users have no choice but to install these binaries with a Nix expression.

## Other Nix builds of HLS<a id="sec-12-2"></a>

There are few different approaches to building and installing HLS with Nix:

-   We can take the officially compiled binaries and patch them for Nix.
-   We can build HLS from scratch, using dependencies pinned by [Nixpkgs](https://github.com/NixOS/nixpkgs).
-   We can build HLS from scratch, using dependencies resolved by [Cabal](https://cabal.readthedocs.io/en/latest/).

Both Joe Kachmar's [easy-hls-nix](https://github.com/jkachmar/easy-hls-nix) and Asad Saeeduddin's [all-hls](https://github.com/masaeedu/all-hls) projects do the first option of patching compiled binaries to work with Nix.

Another convenient way to get HLS for Nix is with [Nixpkgs](https://github.com/NixOS/nixpkgs), the standard repository for getting packages with Nix. This is the second option listed above.

Nixpkgs, easy-hls-nix,and all-hls all have cached or fast-building builds for more versions of GHC than `haskell-hls-nix` (this project) caches. If you don't choose a version (with `--argstr ghcVersion`) cached by this project's continuous integration build, you will have to wait on a build on your local machine. This build may take longer than you have patience for.

What this project offers more uniquely is a build with [Haskell.nix](https://input-output-hk.github.io/haskell.nix/). Building this way offers a few benefits:

-   Dependency resolution is done with Cabal, making it easier to control dependencies.

-   We can target a more recent version of HLS if we want a bleeding-edge fix or feature.

Haskell.nix helps us get the precision of a Nix expression, but using a plan that is resolved by Cabal. This means that for the most part, dependencies are just the latest from a recent pinned state of Hackage. This resolution probably more closely matches the prebuilt binaries officially distributed by the HLS project (patched and redistributed by easy-hls-nix and all-hls).

Nixpkgs has a different approach. Dependencies are shared across all builds provided by Nixpkgs. Resolving dependencies is often contextual to a specific project, so Nixpkgs has the daunting task of getting the whole ecosystem to work with each library pinned to a specific version number. Fortunately, there are people hard at work doing this. But if the build breaks, or you find you want to change a dependency, you may find dealing with overriding and conflict resolution tedious. Nixpkgs is wonderful when it provides you exactly what you need, all prebuilt and cached.

The Haskell.nix approach of this project eases maintenance of building and caching multiple versions of HLS, including something recent from HLS's "main" branch, which as documented you can get with `--arg hlsUnstable`.

## Projects that pre-dated HLS<a id="sec-12-3"></a>

Prior initiatives, [GHCIDE](https://github.com/haskell/ghcide) and [Haskell IDE Engine (HIE)](https://github.com/haskell/haskell-ide-engine), have joined forces behind HLS, so so moving forward you should see that HLS has subsumed these projects. Some people used to prefer to use GHCIDE directly just to get just the compiler feedback and not all of the other features HLS provides (like code formatting). However, this way of [using GHCIDE directly has been deprecated](https://github.com/haskell/ghcide/pull/939).

For both GHCIDE and HIE, there were respective projects maintaining Cachix-cached Nix builds/expressions. GHCIDE had [ghcide-nix](https://github.com/cachix/ghcide-nix) and HIE had [all-hies](https://github.com/Infinisil/all-hies). This project provides something similar for HLS.

# Release<a id="sec-13"></a>

The "main" branch of the repository on GitHub has the latest released version of this code. There is currently no commitment to either forward or backward compatibility.

"user/shajra" branches are personal branches that may be force-pushed to. The "main" branch should not experience force-pushes and is recommended for general use.

# License<a id="sec-14"></a>

All files in this "haskell-hls-nix" project are licensed under the terms of the MIT License.

Please see the [./COPYING.md](./COPYING.md) file for more details.

# Contribution<a id="sec-15"></a>

Feel free to file issues and submit pull requests with GitHub.

There is only one author to date, so the following copyright covers all files in this project:

Copyright © 2020 Sukant Hajra
