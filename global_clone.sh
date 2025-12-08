#!/bin/bash
export SUBDIRECTORY=$1
export BRANCH=$2

if [ -z "$SUBDIRECTORY" ]; then
   echo "missing subdirectory"
    exit
fi

if [ -z "$BRANCH" ]; then
   echo "missing branch"
    exit
fi

git clone --recurse-submodules git@github.com:wbullaughey/alr_environment $SUBDIRECTORY
./check_out.sh $BRANCH
