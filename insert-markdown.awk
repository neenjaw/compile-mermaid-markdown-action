BEGIN {i=0}

(/!\[~mermaid diagram/ && i+1 == n) {skip=2}

(skip == 1 && !/^$/) {print}

skip {skip--; next}

/```mermaid/ {i++}

(/```mermaid/ && i == n) {print link; print ""}

(/```mermaid/ && i == n && hide_codeblocks) {print "<details>\n  <summary>Mermaid markup<summary>\n"; details_open=1}

(/^```$/ && details_open) {print; print "</details>"; details_open=0; next}

{print}
