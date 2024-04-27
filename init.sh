#!/usr/bin/env bash

set -e -u

source "$(git rev-parse --show-toplevel)/scripts/utils.sh"

__get_list_of_release_tags_for_repo() {
  curl -L \
       -H "Accept: application/vnd.github+json" \
       -H "X-GitHub-Api-Version: 2022-11-28" \
       https://api.github.com/repos/"$1"/releases | jq -r ".[] | .tag_name" | grep -v "HEAD" | sort -V | tac
}

__setup_nwnx() {
  # Ask which nwnx version we want to use
  _versions=$(__get_list_of_release_tags_for_repo nwnxee/unified)
  _nwnx_version=$(printf "%s\n" "$_versions" | _pipe_select)

  if [ -z "$_nwnx_version" ]; then
    _die "No version selected"
  elif [ "$_nwnx_version" = "latest" ]; then
    _nwnx_version=$(printf "%s\n" "$_versions" | head -n 2 | tail -n 1)
    printf "Using image 'latest' is not adviced as the local image will not be automatically updated when a new release is published.\nUsing the next option instead: %s\n" "$_nwnx_version"
  fi

  _write_to_env_file IMAGE_TAG "ghcr.io/nwnxee/unified:$_nwnx_version" .env
}

__setup_anvil() {
  # enable plugin nwnx_dotnet
  _write_to_env_file NWNX_DOTNET_SKIP n "$_toplevel/config/nwserver.env"

  # Ask which anvil version we want to use
  _versions=$(__get_list_of_release_tags_for_repo nwn-dotnet/anvil)
  _anvil_version=$(printf "%s\n" "$_versions" | _pipe_select)

  _write_to_env_file IMAGE_TAG "ghcr.io/nwn-dotnet/anvil:$_anvil_version" .env
}

__setup_anvil_plugin() {
  # Ask if we want to create an Anvil plugin
  read -r -p "Do you want to create an Anvil plugin? [Y/n] " _response
  if [[ ! "$_response" =~ ^([nN][oO]|[nN])$ ]]
  then
    # Test if we have dotnet installed
    command -v dotnet >/dev/null 2>&1 || { _warn "dotnet is not installed. We need it to create a plugin for Anvil.\nIf you want help, install dotnet and run this script again."; return 0; }
    dotnet new install NWN.Templates
    read -r -p "Name the plugin folder [default: NWN.MyPlugin] " _plugin_folder
    read -r -p "Name the plugin [default: MyPlugin] " _plugin_name
    _plugin_folder=${_plugin_folder:-NWN.MyPlugin}
    _plugin_name=${_plugin_name:-MyPlugin}
    dotnet new anvilplugin --output "$_plugin_folder" --name "$_plugin_name"
  fi
}


## Main ##

_choice=$(echo -e "nwnx\nAnvil" | _pipe_select)
case $_choice in
  nwnx) __setup_nwnx;;
  Anvil) __setup_anvil; __setup_anvil_plugin;;
  *) _die "Invalid option";;
esac

exit 0
