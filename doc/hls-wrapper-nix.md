- [About `hls-wrapper-nix`](#sec-1)
- [Installation](#sec-2)
- [Editor configuration](#sec-3)
- [Default operation](#sec-4)
- [Configuring by file](#sec-5)
- [Testing a project](#sec-6)
- [Command-line reference](#sec-7)


# About `hls-wrapper-nix`<a id="sec-1"></a>

Our editors need to call HLS, but to get better control of dependencies, some of our projects may need to have HLS invoked within a Nix shell. HLS needs to run in an environment with all the project's dependencies.

Most editors with support for the Language Server Protocol (LSP) have a configuration to specify which executable to call to run HLS for a project. If you used the upstream-recommended `haskell-language-server-wrapper`, then HLS would start, but not with the environment provided by a project's Nix shell.

To get HLS running in the correct environment, this project provides a `hls-wrapper-nix` script that will call `haskell-language-server-wrapper` from within a Nix shell if detected or requested (configurable per-project).

Even if your projects don't require a Nix shell yet, using `hls-wrapper-nix` as a replacement for `haskell-language-server-wrapper` is simple, and provides you flexibility in the future.

This document discusses installation and configuration of `hls-wrapper-nix`. We assume you're familiar with everything discussed in the [root-level README file](../README.md).

Note that you shouldn't use the HLS Nix wrapper script if you're using [Direnv and Lorelei](./direnv.md) to solve the same problem. Direnv and Lorelei has more configuration steps, but can help if the time to enter into a Nix shell is too long and annoying.

# Installation<a id="sec-2"></a>

Install `hls-wrapper-nix` with the Nix expression provided by this project.

If you followed the root-level README's section on a user-based installation, you likely have already installed the script. If not, you can execute the following:

```shell
nix-env --install --file . --attr hls-wrapper-nix
```

    installing 'hls-wrapper-nix'

# Editor configuration<a id="sec-3"></a>

A Language Server Protocol (LSP) -enabled editor will need to know what LSP service to load for a given project. For Haskell projects, the [official HLS instructions](https://github.com/haskell/haskell-language-server#configuring-your-editor) recommend specifying `haskell-language-server-wrapper`. You'll use `hls-wrapper-nix` instead.

How this configuration is specified will vary based on the editor. See the documentation for the plugin your editor uses to provide LSP support.

# Default operation<a id="sec-4"></a>

By default, the HLS Nix wrapper will detect if a project has a `shell.nix` or `default.nix` file, and if so load `haskell-language-server-wrapper` from within a Nix shell. Any arguments not parsed by `hls-wrapper-nix` are passed through to `haskell-language-server-wrapper`, including the `--lsp` switch used by editors to start HLS as a background process.

The Nix shell is invoked with `--pure` by default, which means that any environment variables in your normal user's environment are not available to the invocation of `haskell-language-server-wrapper`, only the environment variables configured by your project's Nix expression.

# Configuring by file<a id="sec-5"></a>

The defaults of `hls-wrapper-nix` may not be appropriate for every project you want to use with HLS. Consider these scenarios:

-   Your project needs to use another Nix file than the detected `shell.nix` or `default.nix`.
-   Your project needs to run an impure Nix shell (no `--pure` switch) so tools installed outside the Nix shell are also included in the environment HLS runs in.

Though `hls-wrapper-nix` can be configured with CLI switches, doing so would require configuring our editors to call different projects differently. Some editors don't make this easy. Furthermore, we'd have to do this configuration for each editor we want to use with HLS.

Instead, we recommend you configure `hls-wrapper-nix` with a centralized configuration file. By default this configuration file will be read from `~/.config/haskell-language-server/wrapper-nix.yaml`.

This file is in the YAML format, and maps a canonical filepath for your project to the project's configuration for `hls-wrapper-nix`.

The canonical filepath mostly resolves symlinks. As a convenience, you can use `nix-wrapper-nix --show-path "$SOME_PATH"` to see exactly how a filepath canonicalizes.

You can configure the following per-project in your YAML file:

-   `mode`: either "detect", "shell", or "bypass"
    -   `detect`: the default behavior to autodetect whether a project requires a `nix-shell` invocation.
    -   `shell`: force invoking HLS from within a Nix shell
    -   `bypass`: invoke HLS directly, bypassing a Nix shell invocation
-   `shell_file`: the relative path to a Nix file to call `nix-shell` with (implies a `mode` of "shell")
-   `pure`: a boolean indicating whether to invoke `nix-shell` with `--pure`

The following is an example of a valid configuration:

```yaml
/home/youruser/src/some-project:
- shell_file: shell-alt.nix
- pure: false
/home/youruser/src/another-project:
- mode: bypass
```

# Testing a project<a id="sec-6"></a>

You should be able to test your configuration of `hls-wrapper-nix` by running it with no arguments at the root of a Haskell project. It should exit successfully with no reported errors.

We can use the provided example projects to illustrate this test. Here's a run of `hls-wrapper-nix` on the Cabal example project:

```shell
hls-wrapper-nix --cwd examples/example-cabal
```

    INFO: Entering pure Nix shell
    Found "/home/tnks/src/shajra/nix-haskell-hls/examples/example-cabal/hie.yaml" for "/home/tnks/src/shajra/nix-haskell-hls/examples/example-cabal/a"
    Module "/home/tnks/src/shajra/nix-haskell-hls/examples/example-cabal/a" is loaded by Cradle: Cradle {cradleRootDir = "/home/tnks/src/shajra/nix-haskell-hls/examples/example-cabal", cradleOptsProg = CradleAction: Multi}
    …
    
    Completed (5 files worked, 0 files failed)
    2021-02-20 12:15:12.596794849 [ThreadId 698] INFO hls:	finish: GenerateCore (took 0.00s)

And here we see that the script works for the Stack example project as well:

```shell
hls-wrapper-nix --cwd examples/example-stack
```

    INFO: Entering pure Nix shell
    Module "/home/tnks/src/shajra/nix-haskell-hls/examples/example-stack/a" is loaded by Cradle: Cradle {cradleRootDir = "/home/tnks/src/shajra/nix-haskell-hls/examples/example-stack", cradleOptsProg = CradleAction: Stack}
    Run entered for haskell-language-server-wrapper(haskell-language-server-wrapper) Version 0.9.0.0 x86_64 ghc-8.10.4
    …
    
    [INFO] finish: User TypeCheck (took 0.11s)
    Completed (3 files worked, 0 files failed)

# Command-line reference<a id="sec-7"></a>

We recommend configuring `hls-wrapper-nix` with a file, but there are CLI switches for configuration that override the configuration file. You may find these useful for testing.

For reference, here's the output of running `hls-wrapper-nix --help`:

    USAGE: hls-wrapper-nix [OPTION]... [HLS_OPTIONS]...
           hls-wrapper-nix --show-path PATH
           hls-wrapper-nix --help
    
    DESCRIPTION:
    
        Run haskell-language-server-wrapper in a nix-shell.
    
    OPTIONS:
    
        --help              print this help message
        --show-path PATH    print path to use in configuration file
        --config PATH       configuration file to read instead of default
        --shell-file PATH   explicitly specified Nix file for shell
        --auto-detect       don't run in Nix shell if not clear how (default)
        --shell-always      always run in a Nix shell
        --shell-never       never run in a Nix shell
        --pure              run pure Nix shell (no external environment)
        --impure            allow external environment variables in Nix shell
        --nix PATH          filepath to 'nix' binary to put on PATH
    
        Note, when using options concurrently (like '--auto-detect',
        '--shell-always', or '--shell-never'), the last one has precedent.
    
    HLS OPTIONS:
    
        --version                Show haskell-language-server-wrapper and GHC versions
        --numeric-version        Show numeric version of
    			     haskell-language-server-wrapper
        --probe-tools            Show haskell-language-server-wrapper version and
    			     other tools of interest
        --lsp                    Start talking to an LSP server
        --cwd DIR                Change to this directory
        --shake-profiling DIR    Dump profiling reports to this directory
        --test                   Enable additional lsp messages used by the testsuite
        --example                Include the Example Plugin. For Plugin devs only
        -d,--debug               Generate debug output
        -l,--logfile LOGFILE     File to log to, defaults to stdout
        -j NUM                   Number of threads (0: automatic) (default: 0)
        --project-ghc-version    Work out the project GHC version and print it
