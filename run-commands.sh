#!/bin/bash

__toplevel=$(git rev-parse --show-toplevel)
__scripts_path="$__toplevel/scripts"
# shellcheck source=./scripts/nwnx_utils.sh
source "$__scripts_path/nwnx_utils.sh"

PS3="Use this menu to run commands. Choose an option: "

options=("docker down & up" "nss watch" "nss all" "pack module" "unpack module" "nwserver restart" "tail server logs" "download all plugin nss")
while true; do
  select option in "${options[@]}" Quit; do
    case $REPLY in
      1) docker compose -f docker-compose.yaml -f docker-compose.dev.yaml down && docker compose -f docker-compose.yaml -f docker-compose.dev.yaml up -d; break;;
      2) "$__scripts_path"/nwn-build.sh compile --watch; break;;
      3) nasher compile; break;;
      4) nasher pack; break;;
      5) nasher unpack; break;;
      6) docker compose restart nwserver; break;;
      7) docker compose logs -f nwserver; break;;
      8) _update_nwnx_nss; break;;
      $((${#options[@]}+1))) break 2;;
      *) echo "invalid option $REPLY"; break;;
    esac
  done
done
