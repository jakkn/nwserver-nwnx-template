#!/usr/bin/env bash

set -e

pipe_select() {
  readarray -t opts
  select foo in "${opts[@]}"
  do
    echo "${foo}";
    break;
  done < /dev/tty
}

VERSIONS=$(curl -L \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/nwnxee/unified/releases | jq -r ".[] | .tag_name" | grep -v "HEAD" | sort -V | tac);

VERSION=$(printf "%s\n" "$VERSIONS" | pipe_select)

if [ -z "$VERSION" ]; then
  echo "No version selected"
  exit 1
elif [ "$VERSION" = "latest" ]; then
  VERSION=$(printf "%s\n" "$VERSIONS" | head -n 2 | tail -n 1)
  printf "Using image 'latest' is not adviced as the local image will not be automatically updated when a new release is published.\nUsing the next option instead: %s\n" "$VERSION"
fi

export VERSION=$VERSION

envsubst < .env > .env.tmp
mv .env.tmp .env

echo "IMAGE_TAG=nwnxee/unified:$VERSION has been written to .env"

exit 0
