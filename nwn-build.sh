#!/bin/bash

set -u

# Make sure our neighbor imports work no matter where we run the script from
__current_dir="${BASH_SOURCE%/*}"
if [[ ! -d "$__current_dir" ]]; then __current_dir="$PWD"; fi
source "$__current_dir/scripts/utils.sh"

__arg1=${1:-pack}
__params=("$__arg1")

while [[ "$#" -gt 0 ]]; do
    shift ## shift past the command for devbase
    case $1 in
        -w|--watch) __watch=1 ;;
        *) [ -n "$1" ] && __params+=("$1") ;; ## If and only if a parameter was passed, add it to the array. Otherwise, devbase will be passed an empty string '' which will break compilation
    esac
    shift
done

if [[ $__arg1 = "compile" && $__watch -gt 0 ]]; then
  command -v entr >/dev/null 2>&1 || { echo >&2 "Watch requires 'entr' but it's not installed. Aborting."; exit 1; }
  echo -e "${_gray}./compile-nss --watch${_nc} 🚀 Started. Watching for file changes... ${_gray}Press Ctrl+C to exit${_nc}"
  trap 'echo "🛑 Shutdown requested. Exiting"; exit' INT
  while sleep 1 ; do find src/nss/ -type f | entr -cdp ./compile-nss.sh /_ ; done ;
fi

# If we're not watching we compile all
nasher compile
