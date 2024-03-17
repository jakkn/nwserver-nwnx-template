#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

FILE="$1"
FILE_NAME=$(basename "$FILE")

EXIT_CODE=0
if [[ -x "$(command -v nasher)" ]]; then
  nasher compile -f:"$FILE_NAME" || EXIT_CODE=$?
fi

if [[ "$EXIT_CODE" -ne 0 ]]; then
  echo -e "${RED}Failed${NC}"
else
  echo -e "${GREEN}Done${NC}"
fi
