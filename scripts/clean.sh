#!/bin/bash

REPO=${1:-all}

INTERACTIVE=${INTERACTIVE:-1}

if [[ "$REPO" == "all" ]]
then
    # all
    REPOS=(embench-iot coremark mibench polybench tacle-bench)
else
    # single
    REPOS=($REPO)
fi

for repo in "${REPOS[@]}"
do
    if [[ "$INTERACTIVE" == "0" ]]
    then
        git -C $repo clean -f
    else
        git -C $repo clean -i
    fi
done
