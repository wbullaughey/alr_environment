#!/bin/bash
COMMENT=$1
if [[ -z "$COMMENT" ]]; then
   echo no comment suppled
else
   function commit(){
      MODULE=$1
      if [[ -d "$MODULE" ]]; then
         pushd $MODULE >/dev/null 2>&1
         if [[ $? -eq 0 ]]; then
            if [[ -n $(git status --porcelain) ]]; then
               echo "commit $MODULE with comment $COMMENT"
               git status
               git add .
               git commit -m "$COMMENT"
               git push
            else
               echo no modified files for $MODULE
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

   commit "ada_lib"
   commit "ada_lib/ada_lib_test_lib"
   commit "ada_lib/ada_lib_tests"
   commit "applications"
   commit "aunit"
   commit "gnoga_lib"
   commit "vendor/github.com/gnoga"
   commit "."
fi

