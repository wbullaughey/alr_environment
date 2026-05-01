#!/bin/sh
echo running $0 at `pwd`
export TOOL=$1
shift

case $SHELL in

   /bin/bash)
      echo "source ~/.bash_profile"
      source ~/.bash_profile
      echo ".bash_profile PATH $PATH"
      ;;

   /bin/zsh)
      echo "source ~/.zshrc"
      source ~/.zshrc
      echo ".zshrc PATH $PATH"
      ;;

   *)
      echo "default PATH $PATH"
      ;;

esac

export GPR_OPTIONS="-v -j10 -d --create-missing-dirs -vP2"
export PROJECT_DIRECTORY=`realpath "$CURRENT_DIRECTORY/.."`
export GPR_DIRECTORY=`realpath "$PROJECT_DIRECTORY/gpr"`
export GNOGA_VERSION=1.5a
export LS3=false
export OS_Type=macosx

echo "GPR_OPTIONS $GPR_OPTIONS"
echo "PROJECT_DIRECTORY $PROJECT_DIRECTORY"
case $GNOGA_VERSION in

    1.5a)
        export GNOGA_PATH="-aP/Users/wayne/vendor/gnoga-1.5a/src -aP/Users/wayne/vendor/gnoga-1.5a/deps/simple_components"
        ;;

    1.5a-installed)
        export GNOGA_PATH="-aP/Users/wayne/vendor/gnoga-1.5a/inst_folder/share/gpr"
        ;;

    aunit)
        export GNOGA_PATH="-aP/Users/wayne/vendor/gnoga-aunit/src -aP/Users/wayne/vendor/gnoga-aunit/deps/simple_components"
        ;;

    *)
        echo unrecognized GNOGA $GNOGA_VERSION
        exit
        ;;

esac
echo "source $GPR_DIRECTORY/set_paths.sh ".."    # parameter MFG_TESTING_RELATIVE"
source $GPR_DIRECTORY/set_paths.sh "../gpr"    # parameter MFG_TESTING_RELATIVE
export EXTRA_PATHS="-aP lib -aP tests $GNOGA_PATH -aP /Users/wayne/vendor/aunit"
echo "source $PROJECT_DIRECTORY/project_build.sh"
source $PROJECT_DIRECTORY/project_build.sh

