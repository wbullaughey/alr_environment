#!/bin/zsh
export OUTPUT=$1        # trace file name
export PROGRAM=$2       # program to execute
export DO_TRACE=$3      # 0 | 1
export HELP_TEST=$4     # options to be tested
export USE_DBDAEMON=$5  # FALSE | TRUE
export UNIT_TEST=$6     # FALSE | TRUE
shift 6
export RUN_PARAMETERS=$*

export APPEND_OUTPUT=""  # first time so output erased
export BUILD_MODE=execute
rm -f TRACE.txt

echo OUTPUT $OUTPUT PROGRAM $PROGRAM DO_TRACE $DO_TRACE HELP_TEST $HELP_TEST \
   USE_DBDAEMON $USE_DBDAEMON UNIT_TEST $UNIT_TEST RUN_PARAMETERS $RUN_PARAMETERS \
    > TRACE.txt
pwd  >> TRACE.txt

function output() {
   TRACE=$1
   shift 1
   echo "output TRACE $TRACE DO_TRACE $DO_TRACE APPEND TRACE $APPEND_OUTPUT \
      PARAMETERS $*" >> TRACE.txt
   case $TRACE in

      "LIST")
         ;;

      "TRACE")
         if [ "$DO_TRACE" -eq 0 ]; then
            return
         fi
   esac
   echo $* 2>&1 | tee $APPEND_OUTPUT $OUTPUT
   export APPEND_OUTPUT=-a  # append from now on
}

# Function to extract first field and update global RUN_PARAMETERS
parse() {
    # Check if global string is empty
    if [[ -z "$RUN_PARAMETERS" ]]; then
        echo "Error: RUN_PARAMETERS is empty"
        return 1
    fi

    # Split string into array
    local fields=(${(s: :)PARAMETERS})
    # Store first field
    local first_field=$fields[1]
    # Return first field
    export RESULT=$first_field
    output TRACE 'parse' PARAMETERS $PARAMETERS RESULT $RESULT fields $fields
}

function extract(){
    # Update global RUN_PARAMETERS
    local fields=(${(s: :)PARAMETERS})
    PARAMETERS=${(j: :)fields[2,-1]}
    output TRACE 'extract' PARAMETERS left $PARAMETERS fields $fields
}

function run() {
   output TRACE run EXECUTE $EXECUTE PROGRAM $PROGRAM COMMAND $COMMAND DISPLAY $DISPLAY

   case "$DISPLAY" in

      true)
         export EXECUTE="$PROGRAM $COMMAND"
         output TRACE EXECUTE $EXECUTE
         ${=EXECUTE} 2>&1 | tee $APPEND_OUTPUT $OUTPUT
         ;;

      false)
         export EXECUTE="$PROGRAM $COMMAND"
         output TRACE EXECUTE $EXECUTE
         ${=EXECUTE} 2>&1| /dev/null
         ;;

      ignore)
         output LIST ignore $PROGRAM $COMMAND
         ;;

   esac
   exit;
}

set -A WORDS ${=RUN_PARAMETERS}
output TRACE words $WORDS

#for PARAMETER in "$WORDS"; do
foreach PARAMETER ($WORDS) {
    output TRACE PARAMETER $PARAMETER
    # Check if parameter starts with '-'
    if [[ ${PARAMETER[1]} == "-" ]]; then        # Concatenate to OPTIONS variable
        output TRACE add option $PARAMETER
        OPTIONS+="$PARAMETER "
    else
        output TRACE add parameter $PARAMETER
        PARAMETERS+="$PARAMETER "
    fi
}

output TRACE RUN_PARAMETERS $RUN_PARAMETERS OPTIONS $OPTIONS PARAMETERS $PARAMETERS

parse
output TRACE 1st parameter $RESULT
case $RESULT in

   "gdb")
      extract
      export GDB=gdb
      ;;

   *)
      ;;

esac

parse
case $RESULT in

   "hide")
      extract
      export DISPLAY=false
      ;;

   "ignore")
      extract
      export DISPLAY=ignore
      ;;

   *)
      export DISPLAY=true
      ;;

esac

parse
export ACTION=$RESULT
output TRACE ACTION $ACTION

case "$ACTION" in

   "help")
      export COMMAND="$OPTIONS -h"
      run
      ;;

   "help_test")
      output LIST Help
      export BUILD_MODE=help_test
      export PROGRAM=bin/help_test
      export COMMAND="$GDB $OPTIONS $HELP_TEST"
      export UNIT_TEST=FALSE
      output TRACE Help Test OPTIONS $OPTIONS HELP_TEST $HELP_TEST COMMAND $COMMAND
      run
      ;;

   "suites")
      output  list suites
      export COMMAND="-@l"
      echo "command: $COMMAND"  | tee -a $OUTPUT
      run
      ;;

esac

case $USE_DBDAEMON in

   FALSE)
      output TRACE check database  "$ACTION"
      case $ACTION in

         "local")
            export DATABASE_OPTION="-l"
            extract
            parse
            ;;

         "remote")
            export DATABASE_OPTION="-r"
            extract
            parse
            ;;
      esac
      ;;

   TRUE)
      output TRACE check database  "$ACTION"
      case $ACTION in

         "connect")
            export DATABASE_OPTION="-l"
            export KILL=false
            ;;

         "local")
            export DATABASE_OPTION="-l -L /Users/wayne/bin/dbdaemon"
            ;;

         "remote")
            export DATABASE_OPTION="-r localhost -R /home/wayne/bin/dbdaemon -u wayne"
            ;;

         "none")
            ;;

         "")
            output LIST no database option provided
            exit
         ;;

         *)
            output LIST unrecognize database option \"$DATABASE\" allowed: local,remote,none
            exit
            ;;

      esac
      export KILL=true
      extract
      parse
      ;;
esac

case $UNIT_TEST in

   TRUE)
      export SUITE=$RESULT
      extract
      parse
      export ROUTINE=$RESULT   # all or test routine name
      extract
      output LIST ACTION $ACTION SUITE $SUITE routine $ROUTINE

      case "$SUITE" in

         all)
            ;;

         "")
            output LIST "missing suite"
            exit;
            ;;

         *)
             export SUITE_OPTION="-s $SUITE"
             ;;

      esac

      case "$ROUTINE" in

         all)
            ;;

         -*)
            output LIST missing routine
            exit;
            ;;

         "")
            output LIST missing routine
            exit;
            ;;

         *)
            output LIST routine $ROUTINE
            export ROUTINE_OPTION="-e $ROUTINE"
            ;;

      esac
      ;;

   FALSE)
      ;;
esac

case $USE_DBDAEMON in

   FALSE)
      ;;

   TRUE)
      ps ax | grep dbdaemon
      killall -9 dbdaemon
      ;;

   false)
       ;;

esac
export COMMAND="$GDB $OPTIONS $DATABASE_OPTION $SUITE_OPTION $ROUTINE_OPTION  -p 2300" # -S 1
output TRACE "command: $COMMAND"
run

sleep 1

