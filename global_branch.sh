#!/bin/bash
export BRANCH=$1

if [ -z "$BRANCH" ]; then
   echo "missing branch label"
    exit
fi

function branch(){
   MODULE=$1
   if [[ -d "$MODULE" ]]; then
      pushd $MODULE >/dev/null 2>&1
      if [[ $? -eq 0 ]]; then
         echo "checkout $MODULE" with "$BRANCH"
         git checkout -b "$BRANCH"
         if [[ $? -eq 0 ]]; then
            echo $MODULE checkout
            git push
            if [[ $? -eq 0 ]]; then
               echo $MODULE pushed
            else
               echo push $MODULE failed
               exit
            fi
         else
            echo branch $MODULE failed
            exit
         fi
         popd >/dev/null 2>&1
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
branch "ada_lib/ada_lib_test_lib"
branch "ada_lib/ada_lib_tests"
branch "applications"
branch "aunit"
branch "gnoga_lib"
branch "vendor/github.com/gnoga"
branch "."

