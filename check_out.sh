#!/bin/bash
export BRANCH=$1

if [ -z "$BRANCH" ]; then
   echo "missing branch label"
    exit
fi

function pull(){
   MODULE=$1
   if [[ -d "$MODULE" ]]; then
      pushd $MODULE >/dev/null 2>&1
      git checkout $BRANCH
      if [[ $? -eq 0 ]]; then
         echo "pull $MODULE"
         git pull
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

pull "ada_lib"
pull "ada_lib/ada_lib_test_lib"
pull "ada_lib/ada_lib_tests"
pull "applications"
pull "aunit"
pull "gnoga_lib"
pull "vendor/github.com/gnoga"
pull "."

