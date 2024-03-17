#!/bin/bash

GRAY='\e[90m'
NC='\033[0m'

ARG1=${1:-pack}
params=("$ARG1")

while [[ "$#" -gt 0 ]]; do
    shift ## shift past the command for devbase
    case $1 in
        -w|--watch) watch=1 ;;
        *) [ -n "$1" ] && params+=("$1") ;; ## If and only if a parameter was passed, add it to the array. Otherwise, devbase will be passed an empty string '' which will break compilation
    esac
    shift
done

if [[ $ARG1 = "compile" && $watch -gt 0 ]]; then
  command -v entr >/dev/null 2>&1 || { echo >&2 "Watch requires 'entr' but it's not installed. Aborting."; exit 1; }
  echo -e "${GRAY}./compile-nss --watch${NC} 🚀 Started. Watching for file changes... ${GRAY}Press Ctrl+C to exit${NC}"
  trap 'echo "🛑 Shutdown requested. Exiting"; exit' INT
  while sleep 1 ; do find src/nss/ -type f | entr -cdp ./compile-nss.sh /_ ; done ;
fi

nasher compile