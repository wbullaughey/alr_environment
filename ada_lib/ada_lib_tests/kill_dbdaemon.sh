#!/bin/sh
echo killall dbdaemon
killall -9 dbdaemon
export RESULT=$?
#echo killall result is /$RESULT/
case $RESULT in

    0)
        echo dbdaemon killed
        ;;

    *)
        echo no dbdaemon left running
        ;;

esac

