#!/bin/bash
export BRANCH=$1
#set -x

if [ -z "$BRANCH" ]; then
   echo "missing branch label"
    exit
fi

function checkout(){
   MODULE=$1
   if [[ -d "$MODULE" ]]; then
      pushd $MODULE >/dev/null 2>&1
      if [[ $? -eq 0 ]]; then
         echo "checkout $MODULE"
	 git pull
         git checkout $BRANCH
         if [[ $? -eq 0 ]]; then
            echo $MODULE updated
         else
            echo update $MODULE failed
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

#checkout "ada_lib"
#checkout "ada_lib/ada_lib_test_lib"
#checkout "ada_lib/ada_lib_tests"
checkout "applications"
checkout "aunit"
checkout "gnoga_lib"
checkout "vendor/github.com/gnoga"
checkout "."

