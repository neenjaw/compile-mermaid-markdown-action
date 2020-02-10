BEGIN {i=0}

(/!\[~mermaid diagram/ && i+1 == n) {skip=2}

skip {skip--; next}

/```mermaid/ {i++}

(/```mermaid/ && i == n) {print link; print ""}

{print}
