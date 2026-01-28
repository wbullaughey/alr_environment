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
   echo pushd to `pwd`
   if [[ $? -eq 0 ]]; then
      echo pushd to `pwd`
   else
      echo pushd to $MODULE failed
      exit
   fi

   echo check in any changes for "$MODULE"
   git add .
   git commit -m "branch $BRANCH"

   echo push module $MODULE
   git push
   if [[ $? -eq 0 ]]; then
      echo module $MODULE pushd
   else
      echo module $MODULE push failed
      exit
   fi

   echo "switch $MODULE" with "$BRANCH"
   git switch -c "$BRANCH"
   if [[ $? -eq 0 ]]; then
      echo module "$MODULE" switched to "$BRANCH"
   else
      echo switch to $MODULE failed
      exit
   fi

   popd >/dev/null 2>&1
   echo poped to `pwd`
}

function push (){
   MODULE=$1
   pushd $MODULE >/dev/null 2>&1
   if [[ $? -eq 0 ]]; then
      echo pushd to `pwd`
      popd >/dev/null 2>&1
      echo poped to `pwd`
   else
       echo "pushd failed"
       exit
   fi

   git push --set-upstream origin $BRANCH
   if [[ $? -eq 0 ]]; then
      echo $MODULE pushed
   else
      echo push $MODULE failed
      exit
   fi
   popd
   echo poped to `pwd`
}

branch "ada_lib"
branch "applications"
branch "aunit"
branch "gnoga_lib"
branch "vendor/github.com/gnoga"
branch "."

push "ada_lib"
push "applications"
push "aunit"
push "gnoga_lib"
push "vendor/github.com/gnoga"
push "."

