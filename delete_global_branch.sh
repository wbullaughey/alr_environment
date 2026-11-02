#!/bin/bash
export ORIGINAL_BRANCH=$1
export DELETE_BRANCH=$2

if [ -z "$ORIGINAL_BRANCH" ]; then
   echo "missing original branch label"
    exit
fi

if [ -z "$DELETE_BRANCH" ]; then
   echo "missing delete branch label"
    exit
fi

function branch(){
   MODULE=$1
   if [[ -d "$MODULE" ]]; then
      pushd $MODULE >/dev/null 2>&1
      if [[ $? -eq 0 ]]; then
         echo "checkout $MODULE" with "$ORIGINAL_BRANCH"
         git checkout "$ORIGINAL_BRANCH"
         if [[ $? -eq 0 ]]; then
            echo $ORIGINAL_BRANCH checked out
            git branch -d $DELETE_BRANCH
            if [[ $? -eq 0 ]]; then
               echo $DELETE_BRANCH deleted
            else
               echo branch delete $DELETE_BRANCH failed
            fi
         else
            echo check out branch $ORIGINAL_BRANCH failed
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

