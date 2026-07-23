#!/bin/bash

function push(){
   MODULE=$1
   if [[ -d "$MODULE" ]]; then
      pushd $MODULE >/dev/null 2>&1
      if [[ $? -eq 0 ]]; then
         echo "push $MODULE"
         git push
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

push "ada_lib"
push "ada_lib/ada_lib_test_lib"
push "ada_lib/ada_lib_tests"
push "applications"
push "aunit"
push "gnoga_lib"
push "vendor/github.com/gnoga"
push "."

