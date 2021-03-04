#!/usr/bin/env bash

# Colors
CSI='\033['
CRED="${CSI}1;31m"
CGREEN="${CSI}1;32m"
CEND="${CSI}0m"

# Files
DIR=$(dirname "$0")
ALL="$DIR/../../all.txt"
NEW="$DIR/../../new.txt"
TMPFILE=$(mktemp)

# Pre-Process
if [ ! -f "$ALL" ]; then
  echo -e "${CRED}Could not find required file \"$ALL\". Aborting.${CEND}"

  exit 1;
fi

if [ ! -f "$NEW" ]; then
  echo -e "${CRED}Could not find required file \"$NEW\". Aborting.${CEND}"

  exit 1;
fi

cp "$ALL" "$TMPFILE"

# Process
COUNTER=0

while IFS= read -r LINE
do
  DOMAIN=${LINE,,}

  # Domain already exists in list, silently ignore it
  if grep -q "$DOMAIN" "$TMPFILE"; then
    continue
  fi

  echo -ne "⌛ Validating $DOMAIN\r"
  
  if [[ "$(dig +short @1.1.1.1 A "$DOMAIN")" =~ ^52\.48\.64\.111|54\.171\.90\.223 ]]; then
    let COUNTER++

    echo -ne "${CGREEN}🟩${CEND} Validating $DOMAIN\\r"
    echo "$DOMAIN" >> "$TMPFILE"
  else
    echo -ne "${CRED}🛑${CEND} Validating $DOMAIN\\r"
  fi

  echo ""
  echo ""
done < "$NEW"

# Post-Process
if [ "$COUNTER" eq 0 ]; then
  echo -e "\n${CRED}No new domains added. Aborting.${CEND}"

  exit 1;
fi

sort -u "$TMPFILE" > "$ALL"

rm "$NEW"
rm "$TMPFILE"

# Regenerate filter list
. "$DIR/generate-filter.sh"

exit 0;
