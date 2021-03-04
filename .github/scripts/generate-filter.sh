#!/usr/bin/env bash

# Colors
CSI='\033['
CRED="${CSI}1;31m"
CGREEN="${CSI}1;32m"
CEND="${CSI}0m"

# Files
DIR=$(dirname "$0")
ALL="$DIR/../../all.txt"
TPL="$DIR/filter.tpl"
FILTERFILE="$DIR/../../filter.txt"
TMPFILE=$(mktemp)

# Pre-Process
if [ ! -f "$ALL" ]; then
  echo -e "${CRED}Could not find required file \"$ALL\". Aborting.${CEND}"

  exit 1;
fi

if [ ! -f "$TPL" ]; then
  echo -e "${CRED}Could not find required file \"$TPL\". Aborting.${CEND}"

  exit 1;
fi

cp "$TPL" "$TMPFILE"

# Process
while IFS= read -r LINE
do
   echo "||${LINE,,}" >> "$TMPFILE"
done < "$ALL"

mv "$TMPFILE" "$FILTERFILE"

exit 0;
