- [Problems solved by Direnv and Lorelei](#sec-1)
- [Comparing Direnv/Lorelei to the HLS Nix wrapper](#sec-2)
- [Installing and configuring Direnv and Lorelei](#sec-3)
- [Editor Configuration](#sec-4)
- [Configuring a project](#sec-5)
- [Testing a project](#sec-6)
- [Suggested advanced configuration](#sec-7)


# Problems solved by Direnv and Lorelei<a id="sec-1"></a>

Our editors need to call HLS, but to get better control of dependencies, some of our projects may need to have HLS invoked within a Nix shell. HLS needs to run in an environment with all the project's dependencies.

Most editors with support for the Language Server Protocol (LSP) have a configuration to specify which executable to call to run HLS for a project. If you used the upstream-recommended `haskell-language-server-wrapper`, then HLS would start, but not with the environment provided by a project's Nix shell.

We've got another problem, though. For some projects, we may find entering a Nix shell a touch slow. The Nix interpreter is not much optimized, and evaluating some Nix expressions can take several seconds.

This document discusses using [Direnv](https://direnv.net/) and [Lorelei](https://github.com/shajra/direnv-nix-lorelei) to solve these problems. We assume you're familiar with everything discussed in the [root-level README file](../README.md).

Note, if you haven't experienced a Nix expression with annoyingly long evaluation times, you don't need to bother with the added complexity of Direnv or Lorelei. You can look into them later. Just use the [HLS Nix wrapper script](./hls-wrapper-nix.md) instead, a more simple alternative to Direnv and Lorelei.

# Comparing Direnv/Lorelei to the HLS Nix wrapper<a id="sec-2"></a>

To set up editors to invoke HLS we have two options to compare:

-   having editors call the HLS Nix wrapper script
-   installing a Direnv extension for our editor, and additionally configuring our projects with Direnv and Lorelei.

The HLS Nix wrapper is relatively simple to set up. You configure an editor with LSP support to call `hls-wrapper-nix` instead of the official `haskell-language-server-wrapper` executable provided by the upstream HLS project. This wrapper then enters into a Nix shell for projects that require it to call HLS properly.

When using `hls-wrapper-nix`, we encounter any slowdowns evaluating a Nix expressions when loading up HLS as a background process. Even if only a one-time pause, it can still be annoying to wait several seconds before getting editor feedback from HLS. This pause isn't strictly one-time. You'll face this pause each time you restart HLS within a Nix Shell.

Direnv allows us a way to dynamically load environment variables at the level of a directory. Direnv is more general than both Haskell and Nix, and many editors have support for Direnv. Once we have an editor configured with a Direnv plugin, when we open a file in a directory associated with a Direnv configuration file, environment variables are loaded as specified. These environment variables can be obtained from the project's Nix shell. With `haskell-language-server-wrapper` and all other required dependencies in the new environment, editors can just call the HLS wrapper directly to start the HLS service.

Lorelei extends Direnv with a library to improve Direnv's built-in Nix support, specifically with respect to caching environment variables determined from entering a Nix shell. This way, we only experience a pause when evaluating a new environment. If we don't change our dependencies, we can experience the pause only the first time we evaluate the environment, and not when we start and stop HLS in our editors.

With Direnv and Lorelei, our editors don't need to know anything about Nix. This is good because Nix is not so popularly used that editors are likely to support it directly. There are, though a number of popularly used editors with reliable Direnv extensions/plugins.

Note, when we change our dependencies there's not much we can do to prevent the inconvenience of recalculating a Nix expression. These dependencies might come from modifications of our Cabal files. Or they might come from changes to the Nix expressions themselves.

Also, note that if you're using Direnv and Lorelei, then you shouldn't need the HLS Nix wrapper script at all. This Nix wrapper script would call `nix-shell` every time you invoke HLS, bypassing any caching benefits of Lorelei and Direnv.

# Installing and configuring Direnv and Lorelei<a id="sec-3"></a>

As a convenience, you can install both [Direnv](https://direnv.net/) and [Lorelei](https://github.com/shajra/direnv-nix-lorelei) with the Nix expression provided by this project. Both projects have full documentation on their respective websites. What follows is a quick guide.

If you followed the root-level README's section on a user-based installation, you have everything you need to use Direnv and Lorelei with Nix. If not, you can execute the following:

```shell
nix-env --install --file . --attr direnv --attr direnv-nix-lorelei
```

    installing 'direnv-2.22.0'
    installing 'direnv-nix-lorelei'

Next, we need to configure Direnv with the Lorelei extension:

```shell
mkdir --parents ~/.config/direnv/lib
ln --symbolic \
    ~/.nix-profile/share/direnv-nix-lorelei/nix-lorelei.sh \
    ~/.config/direnv/lib
```

# Editor Configuration<a id="sec-4"></a>

Please see the [official Direnv documentation on how to configure your editor](https://github.com/direnv/direnv/wiki#editor-integration). Most popular editors have a plugin/extension system, and in general you'll have to find the plugin that provides Direnv support. Some editors may have more than one such plugin.

One configuration you'll have to do with your editors is tell it what executable to call to start the HLS background process. When using Direnv, we recommended that you use `haskell-language-server-wrapper`, and configure your project's Nix shells to provide the necessary executables for this wrapper to run.

Additionally, Direnv has very nice support for enhancing your terminal experience. You can install a hook into your shell so that when you change into a directory configured with Direnv, the environment will automatically change to calculated variables.

# Configuring a project<a id="sec-5"></a>

You're ready to hook your project into Direnv and Lorelei if the following steps have been completed:

-   The Nix package manager is installed
-   Direnv and Lorelei have been installed via Nix
-   The Lorlei script is linked into `~/.config/direnv/lib`
-   Your editor has been extended with a Direnv plugin
-   Your project has a Nix file authored that can be used with `nix-shell`.

If you have a project that can be used to enter a Nix shell with a call like

```shell
nix-shell "$NIX_FILE"
```

for some file `$NIX_FILE`, then at the root of the project you can create a `.envrc` to get started with Direnv:

```shell
echo "use_nix_gcrooted -a \"$NIX_FILE\"" > .envrc
```

And finally, notify Direnv that the configuration file is safe to allow for evaluation:

```shell
direnv allow
```

See the [official documentation for Lorelei](https://github.com/shajra/direnv-nix-lorelei) for more details on this configuration file.

This project provides two example projects, [one that builds with Stack](../examples/example-stack) and [another that builds with Cabal](../examples/example-cabal). These projects both have `.envrc` files. You need to go into these directories and run `direnv allow`, and then if you have performed all the necessary steps discussed in this document, you should be able to load these projects in the editor of your choice to experience HLS.

# Testing a project<a id="sec-6"></a>

You should be able to test your configuration of Direnv and Lorelei with an invocation of `direnv exec`.

We can use the provided example projects to illustrate this test. Here we use `direnv exec` to perform a test run of HLS within the environment picked up by Direnv and Lorelei from the Nix shell of our example Cabal project:

```shell
direnv allow examples/example-cabal
direnv exec examples/example-cabal \
    haskell-language-server-wrapper --cwd "$(pwd)/examples/example-cabal"
```

    ghcide setup tester in /home/tnks/src/shajra/nix-haskell-hls/examples/example-cabal.
    Report bugs at https://github.com/haskell/haskell-language-server/issues
    
    …
    
    Completed (5 files worked, 0 files failed)

Before we can use Direnv with the example, we have to run `direnv allow` on it to permit running code from the `.envrc` file.

Then `direnv exec example/example-cabal` directs Direnv to load an environment specified in `example/example-cabal/.envrc`. This `.envrc` uses Lorelei to get an environment from a Nix shell. The Nix shell of this project provides `haskell-language-server-wrapper` as well as the ICU C library needed for compilation. We can then run the HLS wrapper, specifying the directory to change to with `--cwd`. Because the HLS wrapper exits successful with no report of errors, have confidence that Direnv and Lorelei is configured correctly.

And here we see that the same test works for the Stack example project as well:

```shell
direnv allow examples/example-stack
direnv exec examples/example-stack \
    haskell-language-server-wrapper --cwd "$(pwd)/examples/example-stack" 2>&1
```

    direnv: loading ~/src/shajra/nix-haskell-hls/examples/example-stack/.envrc
    direnv: using user-provided direnv-nix-lorelei
    direnv: not modified: application/example-haskell-app.cabal
    …
    Completed (3 files worked, 0 files failed)
    [INFO] finish: User TypeCheck (took 0.04s)

# Suggested advanced configuration<a id="sec-7"></a>

When dependencies change in a Cabal file or in your project's Nix expression, you'll need to restart HLS. But before you restart HLS, you'll have to recalculate a new environment. Editors normally have keybindings to do each of these:

-   restart HLS for a project
-   recalculate the Direnv environment for a project

If you know the scripting language for your editor of choice, it can be convenient to configure the keybinding that restarts HLS to also recalculate the Direnv environment.

These extra complications are one reason you may prefer to just stick with `hls-wrapper-nix` if the pause of entering into a Nix shell is not so bad.
