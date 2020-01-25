#!/bin/sh -l

outpath="$1"
mkdir -p "$outpath"
printf "Got path: %s\n" "$outpath"

shift $(( OPTIND - 1 ))

for file in "$@"; do
  if [ -f "$file" ]; then
    printf "Attempting compile of: %s\n" "$file"
    name=$(basename "$file")
    printf "Output to: %s\n" "${outpath}/${name}.png"
    /opt/compile-mermaid/node_modules/.bin/mmdc -i "$file" -o "${outpath}/${name}.png"
  fi
done
