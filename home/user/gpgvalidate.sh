#!/bin/bash

# usage: curlcache URL OUTPUT_FILE

if [ "$(id -u)" != "0" ]; then
        exit 0
fi

set -euo pipefail

cachedir=/tmp/curlcache

url="$1"
dest="$2"
package=$(echo $url | sed 's@https://[^/]*/@@')
mirror=$(echo $url | awk -F/ '{print $3}')
name="$(sha1sum <<< "$package" | cut -d' ' -f1)"
cachef="$cachedir/$name"

mkdir -p "$cachedir"

if [ -f "$cachef" ]; then
	curl -z "$cachef" -# -o "$cachef" -- "$url"
else
	curl -# -o "$cachef" -- "$url"
fi

ln -sf "$cachef" "$dest"

curl -z "$cachef.asc" -s "https://$mirror/s/signatures/$package.asc" -o "$cachef.asc"
if ! gpg --verify "$cachef.asc" "$cachef"; then
	echo -e "\e[31mPackage failed validation - this package is corrupt."
	exit 1
fi
