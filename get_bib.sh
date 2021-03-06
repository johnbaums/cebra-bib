#!/bin/bash

# apt install bibtex2html
# apt install biber
cd /srv/cebra-overview/bib || exit
step=100
for ((i=0; ; i+=$step)); do
  contents=$(curl "https://api.zotero.org/users/1338710/collections/Q4A9CU98/items?key=$1&limit=$step&start=$i&format=bibtex")
  if [ ${#contents} -gt 0 ]
    then
      if [[ $i == 0 ]]
        then
          echo "$contents" | sudo tee tmp.bib > /dev/nul
        else
          echo "$contents" | sudo tee -a tmp.bib > /dev/nul
      fi
    else
      break
  fi <<< $contents
done

# below, use local binary of biber v2.15 (dev), which has a fix for inproceedings requiring editor
if ./biber --tool -V --dieondatamodel tmp.bib; then
  # bib valid
  cp tmp.bib all.bib &&
  bib2bib --no-comment -ob biosecurity-intelligence.bib -c 'keywords : "intel"' all.bib &&
  bib2bib --no-comment -ob citizen-science.bib -c 'keywords : "citizen"' all.bib &&
  bib2bib --no-comment -ob decision-making.bib -c 'keywords : "decision"' all.bib &&
  bib2bib --no-comment -ob expert-judgement.bib -c 'keywords : "expert"' all.bib &&
  bib2bib --no-comment -ob import-risk-analysis.bib -c 'keywords : "import"' all.bib &&
  bib2bib --no-comment -ob inspection-efficiency.bib -c 'keywords : "inspection"' all.bib &&
  bib2bib --no-comment -ob other.bib -c 'keywords : "other"' all.bib &&
  bib2bib --no-comment -ob post-border.bib -c 'keywords : "postborder"' all.bib &&
  bib2bib --no-comment -ob risk-communication.bib -c 'keywords : "communication"' all.bib &&
  bib2bib --no-comment -ob spatial-modelling.bib -c 'keywords : "spatial"' all.bib &&
  git checkout tmp.bib.blg 
fi

# https://unix.stackexchange.com/a/155077/379832
if output=$(git status --porcelain) && [ -n "$output" ]; then
  # Uncommitted changes
  git commit -a -m "Update bib (cron job)" &&
  git push
  rm tmp_bibertool.bib
fi

