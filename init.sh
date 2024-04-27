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


## Main ##

_choice=$(echo -e "nwnx\nAnvil" | _pipe_select)
case $_choice in
  nwnx) __setup_nwnx;;
  *) _die "Invalid option";;
esac

exit 0
