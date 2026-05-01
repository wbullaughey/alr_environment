#!/bin/zsh
export OUTPUT=list-test_ada_lib.txt
export PROGRAM=bin/test_ada_lib
export DO_TRACE=0
export HELP_TEST=" \
   -h -l -P -r -v -x -@c -@d -@i -@l -@m -@p -@P -@s -@S -@t -@u -@x \
   -a abcCehiIlmMoOpPrRsStT@c@d@D@e@E@l@o@s@t \
   -@D adt \
   -e routine \
   -g aego \
   -G o \
   -L path \
   -R path \
   -s suite \
   -t acCdhilmorRsStT@d@T@t \
   -T aceElot \
   -u user  \
   -U aAglprstT"
export USE_DBDAEMON=TRUE

source ../../global_run.sh $OUTPUT $PROGRAM $DO_TRACE $HELP_TEST $USE_DBDAEMON TRUE $*

