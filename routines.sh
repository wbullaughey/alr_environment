#!/bin/zsh
export CURRENT_DIRECTORY=`pwd`
rm $OUTPUT TRACE.txt

function output() {
echo output parameters $* 2>&1 TRACE.txt
   TRACE=$1
   shift 1
   echo "output TRACE $TRACE DO_TRACE $DO_TRACE \
         OUTPUT $OUTPUT $*" 2>&1 | tee -a TRACE.txt
   case $TRACE in

      "LIST")
         ;;

      "TRACE")
         if [ "$DO_TRACE" -eq 0 ]; then
            return
         fi
   esac
   echo $* 2>&1 | tee -a $OUTPUT
}

#realative_path() {
#  output TRACE "relative_path of $1"
#  output TRACE `realpath --relative-to=$CURRENT_DIRECTORY $1`
#  print -r -- `realpath --relative-to=$CURRENT_DIRECTORY $1`
#}

remove_1() {
   PARAMETERS=("${PARAMETERS[@]:1}")
   output TRACE shifted /$PARAMETERS/
}

function run() {
   output TRACE run PROGRAM $PROGRAM OPTIONS $OPTIONS COMMAND $COMMAND

   export EXECUTE="$PROGRAM $OPTIONS $COMMAND"
   output TRACE EXECUTE $EXECUTE
   ${=EXECUTE} 2>&1 | tee $APPEND_OUTPUT $OUTPUT
   exit;
}

PARAMETERS=()
for PARAMETER in $*; do    # put all '-' options into OPTIONS
   export FIRST=${PARAMETER:0:1}
   if [[ "$FIRST" = "-" ]]; then
     output TRACE option: $PARAMETER
     OPTIONS="$OPTIONS $PARAMETER"
   else
     PARAMETERS+=$PARAMETER
     output TRACE PARAMETER /$PARAMETER/ PARAMETERS: /$PARAMETERS/
   fi
done

output TRACE source routines.sh PARAMETERS /$PARAMETERS/ OPTIONS /$OPTIONS/ OUPUT=/$OUTPUT/
output TRACE called from $0
output TRACE first parameter $1



