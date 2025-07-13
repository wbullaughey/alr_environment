#!/bin/zsh
echo build all at `pwd`
pushd ada_lib/ada_lib_tests
echo build ada_lib unit_test at `pwd`
./build.sh
if [[ $? -eq 0 ]]; then
   popd
   cd applications/video/camera
   echo build camera at `pwd`
   ./build.sh
   if [[ $? -eq 0 ]]; then
      pushd unit_test
      echo build camera unit test at `pwd`
      ./build.sh
      if [[ $? -eq 0 ]]; then
         popd
         cd driver
         echo build driver at `pwd`
         ./build.sh
         if [[ $? -eq 0 ]]; then
            cd unit_test
            echo build driver unit test at `pwd`
            ./build.sh
            if [[ $? -eq 0 ]]; then
               echo all built
            else
               echo build driver unit test failed
            fi
         else
            echo build driver failed
         fi
      else
         echo build camera unit test faild
      fi
   else
      echo build camera failed
   fi
else
    echo "ada_lib_test failed"
fi

