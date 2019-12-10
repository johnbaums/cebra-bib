#!/bin/bash

# apt-get install bibtex2html
cd /srv/shiny-server/cebra-overview/bib || exit
step=100
for ((i=0; ; i+=$step)); do
  #contents=$(curl "https://api.zotero.org/groups/2254307/items?format=bibtex&limit=$step&start=$i")
  contents=$(curl "https://api.zotero.org/users/1338710/collections/Q4A9CU98/items?key=$1&limit=$step&start=$i&format=bibtex")
  if [ ${#contents} -gt 0 ]
    then
      if [[ $i == 0 ]]
        then
          echo "$contents" | sudo tee all.bib > /dev/nul
        else
          echo "$contents" | sudo tee -a all.bib > /dev/nul
      fi
    else
      break
  fi <<< $contents
done
bib2bib --no-comment -ob biosecurity-intelligence.bib -c 'keywords : "intel"' all.bib &&
bib2bib --no-comment -ob citizen-science.bib -c 'keywords : "citizen"' all.bib &&
bib2bib --no-comment -ob decision-making.bib -c 'keywords : "decision"' all.bib &&
bib2bib --no-comment -ob expert-judgement.bib -c 'keywords : "expert"' all.bib &&
bib2bib --no-comment -ob import-risk-analysis.bib -c 'keywords : "import"' all.bib &&
bib2bib --no-comment -ob inspection-efficiency.bib -c 'keywords : "inspection"' all.bib &&
bib2bib --no-comment -ob other.bib -c 'keywords : "other"' all.bib &&
bib2bib --no-comment -ob post-border.bib -c 'keywords : "postborder"' all.bib &&
bib2bib --no-comment -ob risk-communication.bib -c 'keywords : "communication"' all.bib &&
bib2bib --no-comment -ob spatial-modelling.bib -c 'keywords : "spatial"' all.bib

# https://unix.stackexchange.com/a/155077/379832
if output=$(git status --porcelain) && [ -n "$output" ]; then
  # Uncommitted changes
  git commit -a -m "Update bib (cron job)" &&
  git push
fi

