#!/bin/zsh
source ~/.zshrc
export WHICH=$1
export PROGRAM=$2
export NO_WARNINGS=$3
export TRACE=1

# WHICH values
#   all     - build everything (help_tests, driver unit tests, applications)
#   execute    - build application or library for subdirectory level
#   help_test  - builds help_test at level

echo build WHICH $WHICH PROGRAM $PROGRAM ALR_OPTIONS $ALR_OPTIONS NO_WARNINGS $NO_WARNINGS
if [[ -z "$PROGRAM" ]]; then
   echo PROGRAM not set in SlickEdit build command
   exit
fi

./global_build.sh $WHICH library $PROGRAM $NO_WARNINGS $TRACE

