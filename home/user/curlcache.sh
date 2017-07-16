#!/bin/bash

# usage: curlcache URL OUTPUT_FILE

set -euo pipefail

cachedir=/tmp/curlcache

url="$1"
dest="$2"
name="$(sha1sum <<< "$url" | cut -d' ' -f1)"
cachef="$cachedir/$name"

mkdir -p "$cachedir"

if [ -f "$cachef" ]; then
	curl -z "$cachef" -# -o "$cachef" -- "$url"
else
	curl -# -o "$cachef" -- "$url"
fi

ln -sf "$cachef" "$dest"

siglocation=$(echo $1 | sed 's@https://cloveros.ga/@@')
curl -z "$cachef.asc" -s https://cloveros.ga/s/signatures/$siglocation.asc -o "$cachef.asc"
if ! gpg --verify $cachef.asc "$cachef"; then
	echo "Package failed validation - this package is corrupt."
fi
