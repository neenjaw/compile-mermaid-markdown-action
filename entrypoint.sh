#!/bin/sh -l

outpath=$(realpath "$1")
mkdir -p "$outpath"
printf "Got path: %s\n" "$outpath"

shift $(( OPTIND - 1 ))

for file in "$@"; do
  if [ -f "$file" ]; then
    printf "Attempting compile of: %s\n" "$file"
    name=$(basename "$filename" | cut -f 1 -d '.')
    printf "Output to: %s\n" "${outpath}/${name}.png"
    mmdc -i "$file" -o "${outpath}/${name}.png"
  fi
done
