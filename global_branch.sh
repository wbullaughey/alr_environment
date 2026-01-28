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
      pushd $MODULE >/dev/null 2>&1
      echo pushd to `pwd`
      if [[ $? -eq 0 ]]; then
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
      else
          echo "pushd failed"
          exit
      fi
   else
       echo "Directory $MODULE does not exist"
       exit
   fi
}
function push (){
   MODULE=$1
   echo branch module $MODULE
   if [[ -d "$MODULE" ]]; then
      pushd $MODULE >/dev/null 2>&1
      echo pushd to `pwd`
      if [[ $? -eq 0 ]]; then
         echo "push $MODULE" with "$BRANCH"
         git add .
         git commit -m "branch $BRANCH"
         git push --set-upstream origin "$BRANCH"
         if [[ $? -eq 0 ]]; then
            echo module "$MODULE" pushed with "$BRANCH"
         else
            echo push $MODULE failed
            exit
         fi
         popd >/dev/null 2>&1
         echo poped to `pwd`
      else
          echo "pushd failed"
          exit
      fi
   else
       echo "Directory $MODULE does not exist"
       exit
   fi
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

