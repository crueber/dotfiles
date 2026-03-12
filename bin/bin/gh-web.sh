#!/bin/bash
REPO=$(gh repo view | head -1 | awk '{ print $2}')
open -a "Brave Browser" https://github.com/$REPO
