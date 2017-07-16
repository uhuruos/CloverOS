#!/bin/bash

# usage: curlcache URL OUTPUT_FILE

set -euo pipefail

cachedir=/tmp/curlcache

url="$1"
dest="$2"
package=$(echo $url | awk -F/ '{print $4"/"$5}')
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

curl -z "$cachef".asc -s https://"$mirror"/s/signatures/"$package".asc -o "$cachef".asc
if ! gpg --verify "$cachef".asc "$cachef"; then
	echo "Package failed validation - this package is corrupt."
fi
