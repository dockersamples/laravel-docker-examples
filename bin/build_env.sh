#!/usr/bin/env bash

uid="$( id -u )"
gid="$( id -g )"

sed "s/UID=1000/UID=$uid/" .env.example > .env
sed -i "" "s/GID=1000/UID=$gid/" .env
