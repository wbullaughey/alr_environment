#!/bin/bash
export TAG=$1
export COMMENT=$2

if [ -z "$TAG" ]; then
   echo "missing tag label"
    exit
fi

if [ -z "$COMMENT" ]; then
   echo "missing comment label"
    exit
fi

function tag(){
   MODULE=$1
   if [[ -d "$MODULE" ]]; then
      pushd $MODULE >/dev/null 2>&1
      if [[ $? -eq 0 ]]; then
         echo "tag $MODULE" with "$COMMENT"
         git tag -a $TAG -m "$COMMENT"
         if [[ $? -eq 0 ]]; then
            echo $MODULE tagged
            git push
            if [[ $? -eq 0 ]]; then
               echo $MODULE pushed
            else
               echo push $MODULE failed
               exit
            fi
         else
            echo tag $MODULE failed
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

tag "ada_lib"
tag "ada_lib/ada_lib_test_lib"
tag "ada_lib/ada_lib_tests"
tag "applications"
tag "aunit"
tag "gnoga_lib"
tag "vendor/github.com/gnoga"
tag "."

