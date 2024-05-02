#!/bin/bash

### Use this script to compile your nss.
### It mainly serves as a target for the "compile --watch" command in nwn-build.sh

set -u

# Make sure our neighbor imports work no matter where we run the script from
__current_dir="${BASH_SOURCE%/*}"
if [[ ! -d "$__current_dir" ]]; then __current_dir="$PWD"; fi
source "$__current_dir/utils.sh"

__file_name=$(basename "$1")

__exit_code=0
if [[ -x "$(command -v nasher)" ]]; then
  nasher compile -f:"$__file_name" || __exit_code=$?
fi

if [[ "$__exit_code" -ne 0 ]]; then
  _die "Failed to compile '$__file_name'"
else
  echo -e "${_green}Done${_nc}"
fi
