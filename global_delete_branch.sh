#!/bin/bash
export BRANCH=$1

if [ -z "$BRANCH" ]; then
   echo "missing branch label"
    exit
fi

function branch(){
   MODULE=$1
   echo branch module $MODULE
   if [[ -d "$MODULE" ]]; then
      echo $MODULE exists
   else
      echo $MODULE does not exists
      exit
   fi

   pushd $MODULE >/dev/null 2>&1
   if [[ $? -eq 0 ]]; then
      echo pushd to `pwd`
   else
      echo pushd to $MODULE failed
      exit
   fi

   echo switch to main
   git switch main
   if [[ $? -eq 0 ]]; then
      echo switch to main
   else
      echo could not switch to main, try master
      git switch master
      if [[ $? -eq 0 ]]; then
         echo switch to master
      else
         echo could not switch to master
      fi
   fi
   echo delete branch $BRANCH for "$MODULE"
   git branch -D $BRANCH
   if [[ $? -eq 0 ]]; then
      echo branch $BRANCH for $MODULE deleted
   else
      echo delete branch $BRANCH for $MODULE failed - may not exist
   fi
   git branch
   popd >/dev/null 2>&1
   echo poped to `pwd`
}


branch "ada_lib"
branch "applications"
branch "aunit"
branch "gnoga_lib"
branch "vendor/github.com/gnoga"
branch "."

