source ~/.zshrc
export TRACE_OPTIONS=$*
export OUTPUT=`pwd`/list-help_tests.txt

echo run help_tests TRACE_OPTIONS $TRACE_OPTIONS   2>&1 | tee $OUTPUT

function run () {
   DIRECTORY=$1
   echo "------ run help_test for $DIRECTORY -------" 2>&1 | tee -a $OUTPUT
   pushd $DIRECTORY

   bin/help_test $TRACE_OPTIONS  2>&1 | tee -a $OUTPUT

   if [[ $? -ne 0 ]]; then
      echo "help_test failed for $DIRECTORY" 2>&1 | tee -a $OUTPUT
      exit
   fi
   popd
   echo "------ completed help_test for $DIRECTORY -------" 2>&1 | tee -a $OUTPUT
}

run "ada_lib/ada_lib_tests"
run "applications/video/camera/unit_test"
run "applications/video/camera"
run "applications/video/camera/driver/unit_test"
run "applications/video/camera/driver"
echo all directories run for help tests 2>&1 | tee -a $OUTPUT


