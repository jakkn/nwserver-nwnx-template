#!/bin/bash

### This script should define all the procedures needed to build the project.
### It mainly acts as a wrapper around compile-nss.sh in order to support the --watch flag.
### But, if you need to define any custom steps to build your module, this is where you'd do it.

set -u

# Make sure our neighbor imports work no matter where we run the script from
__current_dir="${BASH_SOURCE%/*}"
if [[ ! -d "$__current_dir" ]]; then __current_dir="$PWD"; fi
source "$__current_dir/utils.sh"

if [[ -z "${1:-}" ]]; then
  _die "No argument passed to $_blue$0$_nc.\nNothing to do."
fi

__arg1=$1
__params=("$__arg1")

shift # remove argument name before processing options
while [[ "$#" -gt 0 ]]; do
    case "${1:-}" in
        -w|--watch) __watch=1 ;;
        *) echo "Unknown option: ${1:-}" ;;
    esac
    shift
done

if [[ $__arg1 = "compile" ]]; then
  if [ -n "${__watch:-}" ]; then
    command -v entr >/dev/null 2>&1 || { echo >&2 "Watch requires 'entr' but it's not installed. Aborting."; exit 1; }
    echo -e "${_gray}./compile-nss --watch${_nc} 🚀 Started. Watching for file changes... ${_gray}Press Ctrl+C to exit${_nc}"
    trap 'echo "🛑 Shutdown requested. Exiting"; exit' INT
    while sleep 1 ; do find src/nss/ -type f | entr -cdp ./compile-nss.sh /_ ; done ;
  else
    nasher compile
  fi
fi

## Define custom build operations here
