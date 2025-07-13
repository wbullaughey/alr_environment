source ~/.zshrc
export MODE=$1

case $MODE in

   execute)
      export COMMAND="./run.sh" $TRACE_OPTIONS $MODE 2>&1 | tee -a $OUTPUT
      ;;

   help)
      export COMMAND="./run.sh" $TRACE_OPTIONS $MODE 2>&1 | tee -a $OUTPUT
      ;;

   test_help)
      export COMMAND="bin/test_help"
      ;;

   *)
      echo missing or invalid MODE =$MODE=
      exit
      ;;

esac

shift
export TRACE_OPTIONS=$*
export OUTPUT=`pwd`/list-run_all-$MODE.txt
echo MODE $MODE OUTPUT $OUTPUT TRACE OPTIONS $TRACE_OPTIONS

echo run_all_apps MODE $MODE  2>&1 | tee $OUTPUT

function run () {
   DIRECTORY=$1
   echo "------ run $MODE for $DIRECTORY -------" 2>&1 | tee -a $OUTPUT
   pushd $DIRECTORY

   $APPLICATION

   if [[ $? -ne 0 ]]; then
      echo "run $MODE failed for $DIRECTORY" 2>&1 | tee -a $OUTPUT
      exit
   fi
   popd
   echo "------ completed $MODE for $DIRECTORY -------" 2>&1 | tee -a $OUTPUT
}

run "ada_lib/ada_lib_tests"
run "applications/video/camera/unit_test"
run "applications/video/camera"
run "applications/video/camera/driver/unit_test"
run "applications/video/camera/driver"
echo all directories run for $MODE 2>&1 | tee -a $OUTPUT


