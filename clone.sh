#!/bin/bash

function checkout() {
   PATH=$1

   pushd $PATH > /dev/null 2>&1
   if [[ $? -ne 0 ]]; then
      echo "pushd to $PATH failed"
      exit
   fi

   git checkout $BRANCH
   if [[ $? -ne 0 ]]; then
      echo "git checkout for $BRANCH on $PATH failed"
      exit
   fi
   popd
}

if [ "$1" = "help" ]; then
    echo "clone.sh <branch name> <directory to create>"
    exit
fi
export BRANCH=$1
export DIRECTORY=$2

if [ -z "$BRANCH" ]; then
    echo "BRANCH is null or empty"
    exit
fi
if [ -z "$DIRECTORY" ]; then
    echo "DIRECTORY is null or empty"
    exit
fi


git clone --branch <branch-name> --recurse-submodules \
   git@github.com:wbullaughey/alr_environment $DIRECTORY
if [[ $? -ne 0 ]]; then
   echo "clone failed"
   exit
fi

checkout ada_lib
checkout application
checkout gnoga_lib
checkout aunit
checkout vendor/github.com/gnoga
