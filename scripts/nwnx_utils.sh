#!/usr/bin/env bash

set -e -u

# Make sure our neighbor imports work no matter where we run the script from
__current_dir="${BASH_SOURCE%/*}"
if [[ ! -d "$__current_dir" ]]; then __current_dir="$PWD"; fi
source "$__current_dir/utils.sh"


__download_file() {
  local target=$1
  local destination=$2

  ## --fail to stop the download gracefully on 404
  ## --silent to suppress the progress bar
  if curl --fail --silent -o "$destination" "$target"; then
    echo -e "Downloaded ${_blue}${target}${_nc} -> ${_blue}${destination}${_nc}"
  else
    _warn "Cannot find ${_orange}${target}${_nc}. Download manually if needed."
  fi
}

__get_anvil_nwnx_target_sha() {
  local anvil_version=$1
  local anvil_dev_build_version
  anvil_dev_build_version=$(echo "$anvil_version" | awk '{split($0,a,"-dev"); print a[2]}')

  # If anvil dev build, the source code will not be tagged. Use the commit sha instead.
  # Ref https://github.com/nwn-dotnet/Anvil/blob/1e9dfb1fde47e8c15b98e73d0f7e52dd6bdc5f9f/.github/workflows/ci.yml#L162
  if [[ "$anvil_dev_build_version" != "" ]]; then
    local commit_sha
    commit_sha=$(echo "$anvil_dev_build_version" | awk '{split($0,a,".r"); print a[2]}')
    export "$(curl -sSL https://raw.githubusercontent.com/nwn-dotnet/Anvil/"$commit_sha"/.env)"
  else
    export "$(curl -sSL https://raw.githubusercontent.com/nwn-dotnet/Anvil/v"$anvil_version"/.env)"
  fi
}

__get_nwnx_target_sha() {
  local env_file="$_toplevel/.env"
  if [[ ! -f "$env_file" ]]; then
    _die "Cannot find .env file to read IMAGE_TAG from; nowhere to read target nwnx version.";
  fi
  # shellcheck source=../.env
  source "$env_file";

  local tag
  tag=$(echo "$IMAGE_TAG" | cut -d ":" -f 2)
  # If IMAGE_TAG contains 'anvil', read the target nwnx version from the upstream Anvil repo
  if [[ "$IMAGE_TAG" =~ "anvil" ]]; then
    __get_anvil_nwnx_target_sha "$tag"
  elif [[ "$IMAGE_TAG" =~ "nwnxee/unified" ]]; then
    export NWNX_VERSION="$tag"
  else
    export NWNX_VERSION="unknown"
  fi

  echo -e "Using ${_blue}NWNX_VERSION$_nc=$NWNX_VERSION"
}

__fetch_nwnx_nss() {
  local nwnx_target_sha=$1
  local nwnx_url_raw_content="https://raw.githubusercontent.com/nwnxee/unified"

  __download_file "$nwnx_url_raw_content/$nwnx_target_sha/Core/NWScript/nwnx.nss" "$_toplevel/src/nss/nwnx.nss"

  # Find all the plugins that we want to download nss for
  local plugins
  plugins=$(grep -E "_SKIP=n" "$_toplevel"/config/nwserver.env \
    | grep -Eo "NWNX_[A-Z]+"\
    | tr "[:upper:]" "[:lower:]")

  # Loop the plugins and download the respective nss if it exists
  for plugin in $plugins; do
    local plugin_name
    plugin_name=$(cut -d "_" -f 2 <<< "$plugin")
    local nwnx_url
    nwnx_url="${nwnx_url_raw_content}/${nwnx_target_sha}/Plugins/${plugin_name^}/NWScript/${plugin}.nss"
    __download_file "$nwnx_url" "$_toplevel/src/nss/${plugin}.nss"
  done
}

## External utils begins here ##

_update_nwnx_nss() {
  __get_nwnx_target_sha
  __fetch_nwnx_nss "$NWNX_VERSION"
}
