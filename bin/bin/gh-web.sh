#!/bin/bash
REPO=$(gh repo view | head -1 | awk '{ print $2}')
URL="https://github.com/$REPO"
if [[ "$(uname)" == "Darwin" ]]; then
  open -a "Brave Browser" "$URL"
else
  xdg-open "$URL"
fi
