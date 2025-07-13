#!/bin/bash

function pull(){
   MODULE=$1
   if [[ -d "$MODULE" ]]; then
      pushd $MODULE >/dev/null 2>&1
      if [[ $? -eq 0 ]]; then
         echo "pull $MODULE"
         git pull
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

pull "ada_lib"
pull "ada_lib/ada_lib_test_lib"
pull "ada_lib/ada_lib_tests"
pull "applications"
pull "aunit"
pull "gnoga_lib"
pull "vendor/github.com/gnoga"
pull "."

