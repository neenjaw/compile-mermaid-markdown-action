#!/bin/sh -l

outpath=$(realpath "$1")

shift $(( OPTIND - 1 ))

for file in "$@"; do
  if [ -f "$file" ]; then
    name=$(basename "$filename" | cut -f 1 -d '.')

    mmdc -i "$file" -o "${outpath}/${name}.png"
  fi
done
