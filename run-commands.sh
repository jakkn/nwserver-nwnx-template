#!/bin/bash

PS3="Use this menu to run commands. Choose an option: "

options=("docker down & up" "nss watch" "extract module" "nss all" "pack module" "nwserver restart")
while true; do
  select option in "${options[@]}" Quit; do
    case $REPLY in
      1) docker compose down && docker compose -f docker-compose.yaml up -d; break;;
      2) ./nwn-build.sh compile -w; break;;
      3) nasher unpack; break;;
      4) ./nwn-build.sh compile; break;;
      5) nasher pack; break;;
      6) docker restart bop; break;;
      $((${#options[@]}+1))) break 2;;
      *) echo "invalid option $REPLY"; break;;
    esac
  done
done
