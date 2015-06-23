#!/bin/bash

echo "$(date) Cleaning Virtuoso HTTP logs. Only keep 5 most recent files"
find . -maxdepth 1 -type f -name 'http*.log' | xargs -x ls -t | awk 'NR>5' | xargs -L1 rm
