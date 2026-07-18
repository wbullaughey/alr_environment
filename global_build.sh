source ~/.zshrc
export WHICH=$1         # all | both | execute | help_test
export KIND=$2
export PROGRAM=$3
export NO_WARNINGS=$4
export DIRECTORY=`pwd`
export SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
export DO_TRACE=FALSE
export MACOSX_DEPLOYMENT_TARGET=14.0
echo SCRIPT_DIR $SCRIPT_DIR
#SCRIPT_DIR=$(dirname "$0")
#echo SCRIPT_DIR $SCRIPT_DIR
#export DEBUG_OPTIONS="-vv -d"
#export DEBUG_OPTIONS="-d"
#export ALR_OPTIONS="$ALR_OPTIONS -aP $SCRIPT_DIR"
#echo ALR_OPTIONS $ALR_OPTIONS
export ADAFLAGS=""
#echo ALR_OPTIONS $ALR_OPTIONS

#ls $SCRIPT_DIR

# WHICH values
#   all     - build everything (help_tests, driver unit tests, applications)
#   execute    - build application or library for subdirectory level
#   help_test  - builds help_test at level

if [[ -z "$PROGRAM" ]]; then
   echo PROGRAM not set in build.sh
   exit
fi

function output() {
   TRACE=$1
   shift 1
#  echo "output TRACE $TRACE DO_TRACE $DO_TRACE APPEND TRACE $APPEND_OUTPUT \
#     PARAMETERS $*" >> TRACE.txt
   case $TRACE in

      "LIST")
         ;;

      "TRACE")
         case $DO_TRACE in

            "FALSE")
               return
               ;;

            "TRUE")
               ;;
         esac
         ;;

   esac
   echo $* 2>&1 | tee $APPEND_OUTPUT $OUTPUT
   export APPEND_OUTPUT=-a  # append from now on
}

WHICH_ALR=`which alr`
#output TRACE PATH $PATH
#output TRACE which alr $WHICH_ALR
output LIST global build WHICH $WHICH DIRECTORY $DIRECTORY
output TRACE global build PROGRAM $PROGRAM SCRIPT_DIR $SCRIPT_DIR KIND $KIND DO_TRACE $DO_TRACE

case $KIND in

   library)
      ;;

   program)
      ;;

   *)
      output LIST missing or bad KIND $KIND
      exit;
      ;;

esac

function build () {
   DIRECTORY=$1
   BUILD_MODE=$2
   if [[ "$BUILD_MODE" = "help_test" && "$KIND" = "library" ]]; then
      output LIST no build help build for $DIRECTORY BUILD_MODE $BUILD_MODE kind $KIND
   else
      output TRACE building $DIRECTORY BUILD_MODE $BUILD_MODE kind $KIND

      pushd $DIRECTORY > /dev/null 2>&1
      if [[ $? -ne 0 ]]; then
         echo "pushd to $DIRECTORY failed"
         exit
      fi
   #  echo building `pwd` BUILD_MODE $BUILD_MODE
#     $SCRIPT_DIR/fix_alire_toml.sh alire.toml.source
      COMMAND="alr $DEBUG_OPTIONS build -- -j10 -s -k -gnatE -vl -v $ALR_OPTIONS -XBUILD_MODE=$BUILD_MODE -largs"

      output TRACE COMMAND $COMMAND
#     echo pwd `pwd`
      RESULT=$(eval "$COMMAND")
      STATUS=$?
      popd

      if [ "$STATUS" -eq 0 ]; then
          echo "build for $DIRECTORY succeeded"
          echo "RESULT $RESULT STATUS $STATUS"
      else
          echo "build Failed with STATUS $STATUS for $DIRECTORY"
          echo "RESULT $RESULT STATUS $STATUS"
          exit
      fi

#     if [[ -n "$NO_WARNINGS" ]]; then
#        output TRACE NO WARNINGS $NO_WARNINGS
#        set LIST = `eval "$COMMAND"`
#        if [[ $? -ne 0 ]]; then
#           echo "build for $DIRECTORY failed"
#           grep -v -e "warning" -e "style" LIST
#           exit
#        else
#           echo LIST $LIST
#           echo "build for $DIRECTORY succeeded"
#        fi
#     else
#        eval $COMMAND
#
#        if [[ $? -ne 0 ]]; then
#           echo "build for $DIRECTORY failed with status $?"
#        else
#           echo "build for $DIRECTORY succeeded with status $?"
#        fi
#     fi
#echo run install_name_tool
#      install_name_tool -delete_rpath /Users/wayne/.local/share/alire/toolchains/gnat_native_14.2.1_cc5517d6/lib bin/$PROGRAM
#      if [[ $? -ne 0 ]]; then
#         echo "install_name_tool for $DIRECTORY failed"
#      else
#         echo "install_name_tool for $DIRECTORY succeeded"
#      fi
   fi
}

function build_all () {
   BUILD_MODE=$1
   echo build_all for BUILD_MODE $BUILD_MODE
   CURRENT_DIR=`pwd`
   if [[ $SCRIPT_DIR != $CURRENT_DIR ]]; then
      echo "not building from global_build.sh directory"
      exit
   fi
   build "aunit" $BUILD_MODE
   build "ada_lib" $BUILD_MODE
   build "ada_lib/aunit" $BUILD_MODE
   build "ada_lib/ada_lib_test_lib" $BUILD_MODE
   build "ada_lib/ada_lib_tests" $BUILD_MODE
   build "applications/video/camera" $BUILD_MODE
   build "applications/video/camera/driver" $BUILD_MODE
   build "applications/video/camera/driver/unit_test" $BUILD_MODE
   build "applications/video/camera/unit_test" $BUILD_MODE
   build "gnoga_lib/gnoga_ada_lib" $BUILD_MODE
   build "gnoga_lib/gnoga_options" $BUILD_MODE
   build "vendor/github.com/gnoga" $BUILD_MODE
   build "." $BUILD_MODE
   echo all directories built for BUILD_MODE $BUILD_MODE
}

case $WHICH in

   all)
      echo build all
      build_all execute
      build_all help_test
      echo both execute and help_test built
      ;;

   both)
      echo build both
      build $DIRECTORY execute
      build $DIRECTORY help_test
      ;;

   clean)
      ALR_OPTIONS="$ALR_OPTIONS -f"
      echo build execute
      build $DIRECTORY execute
      ;;

   aunit | execute)
      echo build $WHICH
      build $DIRECTORY $WHICH
      ;;

   help_test)
      echo build help test
      build $DIRECTORY $WHICH
      ;;

   *)
      echo missing or bad WHICH
      exit;
      ;;

esac


