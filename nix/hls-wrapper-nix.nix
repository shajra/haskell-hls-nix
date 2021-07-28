{ coreutils
, findutils
, gnugrep
, gnused
, hls-wrapper
, nix-project-lib
, yq-go
}:

let
    progName = "hls-wrapper-nix";
    meta.description =
        "Haskell Language Server (HLS) wrapper for Nix";
in

nix-project-lib.writeShellCheckedExe progName
{
    inherit meta;
    pathPure = false;
    path = [
        coreutils
        gnugrep
        gnused
        hls-wrapper
        yq-go
    ];
}
''
set -eu
set -o pipefail

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
    cat - <<EOF
USAGE: ${progName} [OPTION]... [HLS_OPTIONS]...
       ${progName} --show-path PATH
       ${progName} --help

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
            readlink -f "$to_show"
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
    work_dir="$(readlink -f "$work_dir")"

    local config=""
    if test -r "$DEFAULT_CONFIG" || test -n "$CONFIG"
    then
        local config_file="''${CONFIG:-"$DEFAULT_CONFIG"}"
        log_info "using config file: $config_file"
        log_info "config file key: $work_dir"
        validate_config_file "$config_file" "$work_dir"
        config="$(yq eval ".\"$work_dir\"" "$config_file")"
    fi
    if [ -z "$config" ]
    then
        local default_yq='.mode |= "detect" | .pure |= true'
        config="$(yq --null-input eval "$default_yq")"
    fi
    if [ -z "$SHELL_FILE" ]
    then SHELL_FILE="$(echo "$config" \
            | yq eval '.shell_file // ""' -)"
    fi
    if [ -z "$MODE" ]
    then MODE="$(echo "$config" | yq eval '.mode' -)"
    fi
    if [ "$MODE" = "null" ]
    then MODE="detect"
    fi
    if [ -z "$NIX_PURE" ]
    then NIX_PURE="$(echo "$config" | yq eval '.pure' -)"
    fi
    if [ "$NIX_PURE" = "null" ]
    then NIX_PURE="true"
    fi
}

validate_args()
{
    case "$MODE" in
         detect|shell|bypass) ;;
         *) die_helpless "'mode' not \"detect\", \"shell\", or \"bypass\": $MODE" ;;
    esac
    case "$NIX_PURE" in
         true|false) ;;
         *) die_helpless "'pure' not \"true\" or \"false\": $NIX_PURE" ;;
    esac
    if ! [ -r "$(shell_file)" ]
    then die_helpless "shell file unreadable: $(shell_file)"
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
        exec haskell-language-server-wrapper \"\''${HLS_ARGS[@]}\"
        "
}

call_without_shell()
{
    log_info "Not entering Nix shell"
    exec haskell-language-server-wrapper "''${HLS_ARGS[@]}"
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

validate_config_file()
{
    local config_file="$1"
    local work_dir="$2"
    local yq_expr
    local yq_res
    if ! yq eval true "$config_file" > /dev/null
    then die_helpless "config file malformed: $config_file"
    fi
    yq_res="$(yq eval "tag" "$config_file")"
    if [ -z "$yq_res" ]  # DESIGN: empty config file
    then return 0
    fi
    if ! [ "$yq_res" = "!!map" ]
    then die_helpless "config file not a YAML map"
    fi
    yq_expr=".\"$work_dir\" | tag"
    yq_res="$(yq eval "$yq_expr" "$config_file")"
    if ! [ "$yq_res" = "!!map" ] && ! [ "$yq_res" = "!!null" ]
    then die_helpless "config entry for '$work_dir' not a map"
    fi
}

hls_options()
{
    haskell-language-server-wrapper --help \
    | grep -A99 options: \
    | sed '/options:/d;s/^/  /;/--help/d'
}

log_info()
{
    echo "INFO: $*" >&2
}


main "$@"
''
