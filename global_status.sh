#!/bin/bash
function status(){
   MODULE=$1
   if [[ -d "$MODULE" ]]; then
      pushd $MODULE >/dev/null 2>&1
      if [[ $? -eq 0 ]]; then
         echo "checkout $MODULE" with "$BRANCH"
         git status
         if [[ $? -eq 0 ]]; then
            echo got $MODULE status

         else
            echo status $MODULE failed
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

status "ada_lib"
status "ada_lib/ada_lib_test_lib"
status "ada_lib/ada_lib_tests"
status "applications"
status "aunit"
status "gnoga_lib"
status "vendor/github.com/gnoga"
status "."

