#!/bin/bash

### This script contains various bash utility functions for the project.

set -u

export _blue='\033[0;34m'
export _gray='\e[90m'
export _green='\033[0;32m'
export _nc='\033[0m'
export _orange='\033[0;33m'
export _red='\033[0;31m'

_toplevel=$(git rev-parse --show-toplevel)
export _toplevel

_warn() {
  echo >&2 "${_orange}WARN${_nc}:: $*"
}

_die() {
  echo -e >&2 "${_red}ERROR${_nc}:: $*"
  exit 1
}

# Overwrite key-value pairs in .env
_write_to_env_file() {
  local key=$1 value=$2 env_file=$3

  if [[ ! -f $env_file ]]; then
    _die "$env_file does not exist"
  fi
  if [[ ! "$key" ]]; then
    _die "Missing key when writing to $env_file"
  fi

  if ! grep -q "$key=" "$env_file"; then
      echo "$key=" >> "$env_file" # Create variable if missing
  fi

  echo -e "\nWrite $_gray$env_file$_nc:"
  echo -e "$_blue$key$_nc=$value\n"

  sed -i -e "s|$key=.*|$key=$value|" "$env_file" # non-standard delimiter because $value contains slashes
}

_yaml_append() {
  local key=$1 value=$2 file=$3

  echo -e "\nWrite $_gray$file$_nc:"
  echo -e "$_blue$key$_nc: $_orange\"$value\"$_nc\n"

  if [[ ! -f $file ]]; then _die "$file does not exist"; fi
  if [[ ! $key ]]; then _die "key not specified" 1>&2; fi
  if [[ ! $value ]]; then _die "value not specified" 1>&2; fi

  # yq strips witespaces and newlines, so we parse the diff and patch it to preserve as much of the original content as possible
  # See https://github.com/mikefarah/yq/issues/515
  yq eval "$key += \"$value\"" "$file" | diff -Bw --strip-trailing-cr "$file" - | patch "$file" -
}

# Takes a list of options and prompts the user to select one, returning the selected option
_pipe_select() {
  readarray -t opts
  select option in "${opts[@]}"
  do
    echo "${option}";
    break;
  done < /dev/tty
}
