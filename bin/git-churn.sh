#!/bin/bash

git log --all --name-only --format='format:' | grep -v '^$' |sort | uniq -c | sort
