{ coreutils
, findutils
, gnugrep
, gnused
, hls-wrapper
, nix-project-lib
, yq-go
}:

let
    name = "hls-wrapper-nix";
    meta.description =
        "Haskell Language Server (HLS) wrapper for Nix";
in

nix-project-lib.writeShellCheckedExe name
{
    inherit meta;
}
''
set -eu

DEFAULT_CONFIG="$HOME/.config/haskell-language-server/wrapper-nix.yaml"
CONFIG=
NIX_EXE="$(command -v nix || true)"
SHELL_FILE=
WORK_DIR=
NIX_PURE=
MODE=  # detect | shell | bypass
HLS_ARGS=()


. "${nix-project-lib.lib-sh}/share/nix-project/lib.sh"

print_usage()
{
    "${coreutils}/bin/cat" - <<EOF
USAGE: $("${coreutils}/bin/basename" "$0") [OPTION]... [HLS_OPTIONS]...
       $("${coreutils}/bin/basename" "$0") --show-path PATH
       $("${coreutils}/bin/basename" "$0") --help

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

$(hls_options)
EOF
}

main()
{
    while ! [ "''${1:-}" = "" ]
    do
        case "$1" in
        -h|--help)
            print_usage
            exit 0
            ;;
        --show-path)
            local to_show="''${2:-}"
            if [ -z "$to_show" ]
            then die "$1 requires argument"
            fi
            "${coreutils}/bin/readlink" -f "$to_show"
            exit 0
            ;;
        --config)
            CONFIG="''${2:-}"
            if [ -z "$CONFIG" ]
            then die "$1 requires argument"
            fi
            shift
            ;;
        --nix)
            NIX_EXE="''${2:-}"
            if [ -z "$NIX_EXE" ]
            then die "$1 requires argument"
            fi
            shift
            ;;
        --auto-detect)
            MODE=detect
            ;;
        --shell-always)
            MODE=shell
            ;;
        --shell-never)
            MODE=bypass
            ;;
        --shell-file)
            SHELL_FILE="''${2:-}"
            if [ -z "$SHELL_FILE" ]
            then die "$1 requires argument"
            fi
            shift
            MODE=shell
            ;;
        --cwd)
            WORK_DIR="''${2:-}"
            if [ -z "$WORK_DIR" ]
            then die "$1 requires argument"
            fi
            shift
            ;;
        --pure)
            NIX_PURE=true
            ;;
        --impure)
            NIX_PURE=false
            ;;
        *)
            HLS_ARGS+=("$1")
            ;;
        esac
        shift
    done

    if [ -n "$NIX_EXE" ]
    then add_nix_to_path "$NIX_EXE"
    fi
    if [ -n "$WORK_DIR" ] && [ -d "$WORK_DIR" ]
    then cd "$WORK_DIR" || die "can not change to directory: $WORK_DIR"
    fi
    integrate_args
    validate_args
    if should_use_shell
    then call_with_shell
    else call_without_shell
    fi
}

integrate_args()
{
    local work_dir
    work_dir="$(pwd)"
    work_dir="$("${coreutils}/bin/readlink" -f "$work_dir")"

    local config=""
    if test -r "$DEFAULT_CONFIG" || test -n "$CONFIG"
    then
        local config_file="''${CONFIG:-"$DEFAULT_CONFIG"}"
        log_info "using config file: $config_file"
        if "${yq-go}/bin/yq" v "$config_file"
        then config="$("${yq-go}/bin/yq" r "$config_file" ["$work_dir"])"
        else die "config file malformed: $config_file"
        fi
    fi

    if [ -z "$SHELL_FILE" ]
    then SHELL_FILE="$(echo "$config" \
            | "${yq-go}/bin/yq" r - "[shell_file]")"
    fi
    if [ -n "$SHELL_FILE" ]
    then MODE=shell
    fi
    if [ -z "$MODE" ]
    then MODE="$(echo "$config" \
            | "${yq-go}/bin/yq" r - "[mode]" --defaultValue detect)"
    fi
    if [ -z "$NIX_PURE" ]
    then NIX_PURE="$(echo "$config" \
            | "${yq-go}/bin/yq" r - "[pure]" --defaultValue true)"
    fi
}

validate_args()
{
    case "$MODE" in
         detect|shell|bypass) ;;
         *) die "'mode' not \"detect\" \"shell\" or \"bypass\": $MODE" ;;
    esac
    case "$NIX_PURE" in
         true|false) ;;
         *) die "'pure' not \"true\" or \"false\": $NIX_PURE" ;;
    esac
    if ! [ -r "$(shell_file)" ]
    then die "shell file unreadable: $(shell_file)"
    fi
}

should_use_shell()
{
    if [ -n "''${IN_NIX_SHELL:-}" ]
    then
        log_info "Already in Nix shell"
        false
    elif [ "$MODE" = bypass ]
    then false
    elif [ "$MODE" = shell ]
    then
        log_info "Entering Nix shell forcibly: $(shell_file)"
        true
    elif [ "$MODE" = detect ]
    then test -r "$(shell_file)"
    else die "mode not 'bypass', 'shell', or 'detect': $MODE"
    fi
}

call_with_shell()
{
    local file; file="$(shell_file)"
    if ! [ -r "$file" ]
    then die "can't read Nix file for Nix shell: $file"
    fi
    local pure_arg=(--pure)
    local pure_type=pure
    if [ "$NIX_PURE" = false ]
    then
        pure_arg=()
        pure_type=impure
    fi
    log_info "Entering ''${pure_type} Nix shell"
    nix-shell "''${pure_arg[@]}" \
        "$file" \
        --run \
        "
        $(declare -p HLS_ARGS)
        exec \"${hls-wrapper}/bin/haskell-language-server-wrapper\" \
            \"\''${HLS_ARGS[@]}\"
        "
}

call_without_shell()
{
    log_info "Not entering Nix shell"
    exec "${hls-wrapper}/bin/haskell-language-server-wrapper" \
        "''${HLS_ARGS[@]}"
}

shell_file()
{
    if [ -n "$SHELL_FILE" ]
    then echo "$SHELL_FILE"
    elif [ -f "shell.nix" ]
    then echo "shell.nix"
    elif [ -f "default.nix" ]
    then echo "default.nix"
    fi
}

hls_options()
{
    "${hls-wrapper}/bin/haskell-language-server-wrapper" --help \
    | "${gnugrep}/bin/grep" -A99 options: \
    | "${gnused}/bin/sed" '/options:/d;s/^/  /;/--help/d'
}

log_info()
{
    echo "INFO: $*" >&2
}


main "$@"
''
