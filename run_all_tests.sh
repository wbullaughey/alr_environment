source ~/.zshrc

export TRACE_OPTIONS=$*
export OUTPUT=`pwd`/list-run_all_unit_tests.txt
echo OUTPUT $OUTPUT TRACE OPTIONS $TRACE_OPTIONS

echo run_all_apps MODE $MODE 2>&1 | tee $OUTPUT

function run () {
   DIRECTORY=$1
   COMMAND=$2
   OPTIONS=$3
   echo "------ run unit tests for $DIRECTORY -------" 2>&1 | tee -a $OUTPUT
   pushd $DIRECTORY

   ./run.sh $TRACE_OPTIONS $OPTIONS 2>&1 | tee -a $OUTPUT

   if [[ $? -ne 0 ]]; then
      echo "run $MODE failed for $DIRECTORY" 2>&1 | tee -a $OUTPUT
      exit
   fi
   popd
   echo "------ completed unit tests for $DIRECTORY -------" 2>&1 | tee -a $OUTPUT
}

run "ada_lib/ada_lib_tests" "./run.sh" "local all all"
run "applications/video/camera/unit_test" "./driver_test.sh" test
run "applications/video/camera/driver/unit_test" "./run.sh"
echo all tests in directories run 2>&1 | tee -a $OUTPUT


