# nwserver-nwnx-template

Template for nwnee projects with nwnx installed, running Docker.

Useful to get quickly up and running for proof of concepts, testing features, or reproducing bugs.

## Getting started

### Init

1. Run `./init.sh` to get started with an nwnx version
1. Run `nasher init` to get started with the project sources

### Use

Use [nasher](https://github.com/squattingmonk/nasher) to manage the sources.

A utility script named `./run-commands.sh` has been added to speed up running frequent commands, inlcuding a useful watch-utility to hot compile scripts on file save (option 2).

## Requirements

- `docker` (with `compose`)
- `nasher`
- `entr` (to hot compile)
