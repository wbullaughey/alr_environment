#!/bin/zsh
#set -x
export VERBOSE=$1
export RELATIVE_PATH=Project/git/alr/alr_environment
export SOURCE=/Users/wayne/$RELATIVE_PATH
export DESTINATION=/Volumes/wayne/$RELATIVE_PATH
export OUTPUT=$SOURCE/rsync.txt
echo rsync VERBOSE $VERBOSE  2>&1 | tee $OUTPUT
if [ -z "$VERBOSE" ]; then # not verbose
   export OPTIONS="-lptvq"
else                       # verbose
   export OPTIONS="-lptv"
fi

echo OPTIONS $OPTIONS

function report {
   kind=$1
   what=$2
   level=$3

   case $level in

      "warning")
         if [ -n "$VERBOSE" ]; then
            echo "warning: $kind $what does not exist"
         fi
         ;;

      "error")
         echo "error: $kind $what does not exist"
         ;;

      *)
         echo "missing level for $kind $what"
         ;;
   esac
}

function copy_file {
   DIRECTORY=$1
   FILE=$2
   LEVEL=$3
   COMMAND="rsync $OPTIONS --progress $SOURCE/$DIRECTORY/$FILE $DESTINATION/$DIRECTORY"
   if [ -n "$VERBOSE" ]; then
      echo "copy file: $FILE directory: $DIRECTORY
      echo "options: $OPTIONS"
      echo "source: $SOURCE"
      echo "destination: $DESTINATION
      pwd
      echo $COMMAND
   fi
   if [[ -e $SOURCE/$DIRECTORY/$FILE ]]; then
      if [ -d "$DESTINATION" ]; then
         eval $COMMAND

      else
         report destination $DESTINATION $LEVEL
      fi
   else
      report file $SOURCE/$DIRECTORY/$FILE $LEVEL
   fi
}

function copy_directory {
   DIRECTORY=$1
   if [ -n "$VERBOSE" ]; then
      echo "copy directory: $DIRECTORY"
      echo "options: $OPTIONS"
      echo "source: $SOURCE "
      echo "destination: $DESTINATION"
      echo "rsync directory $OPTIONS $SOURCE/$DIRECTORY/src/* $DESTINATION/$DIRECTORY/src"
      pwd
   fi

   if [ -d "$SOURCE/$DIRECTORY" ]; then
      if [ -d "$DESTINATION" ]; then

         rsync $OPTIONS $SOURCE/$DIRECTORY/*.gpr $DESTINATION/$DIRECTORY
         rsync $OPTIONS $SOURCE/$DIRECTORY/src/* $DESTINATION/$DIRECTORY/src

         if [ -d "$SOURCE/$DIRECTORY/config" ]; then
            rsync $OPTIONS $SOURCE/$DIRECTORY/config/* $DESTINATION/$DIRECTORY/config
#        else
#           report source "$SOURCE/$DIRECTORY/config warning"
         fi
         copy_file $DIRECTORY alire.toml warning
         copy_file $DIRECTORY project_paths.cfg warning
      else
         report destination $DESTINATION error
      fi
   else
      report source $SOURCE/$DIRECTORY error
   fi
}

echo "rsync source $SOURCE destination $DESTINATION" 2>&1 | tee $OUTPUT

copy_directory "./" 2>&1 | tee -a $OUTPUT
copy_directory "ada_lib" 2>&1 | tee -a $OUTPUT
copy_directory "ada_lib/ada_lib_gnoga" 2>&1 | tee -a $OUTPUT
copy_directory "ada_lib/ada_lib_tests" 2>&1 | tee -a $OUTPUT
copy_directory "aunit" 2>&1 | tee -a $OUTPUT
copy_directory "aunit/ada_lib" 2>&1 | tee -a $OUTPUT
# use git to check in and out vendor/github.com/gnoga
copy_directory "applications/video/camera" 2>&1 | tee -a $OUTPUT
copy_directory "applications/video/camera/lib" 2>&1 | tee -a $OUTPUT
#copy_directory "applications/video/camera/lib/unit_test" 2>&1 | tee -a $OUTPUT
copy_directory "applications/video/camera/test_lib" 2>&1 | tee -a $OUTPUT
copy_directory "applications/video/camera/unit_test" 2>&1 | tee -a $OUTPUT
copy_directory "applications/video/camera/driver" 2>&1 | tee -a $OUTPUT
copy_directory "applications/video/camera/driver/unit_test" 2>&1 | tee -a $OUTPUT
copy_directory "applications/video/lib" 2>&1 | tee -a $OUTPUT
copy_directory "applications/video/lib/video_aunit" 2>&1 | tee -a $OUTPUT

copy_file ./ remote_build.sh error 2>&1 | tee -a $OUTPUT
copy_file ada_lib/ada_lib_tests build.sh error 2>&1 | tee -a $OUTPUT
#copy_file video/camera build.sh error 2>&1 | tee -a $OUTPUT
copy_file applications/video/camera/driver build.sh error 2>&1 | tee -a $OUTPUT
copy_file applications/video/camera/driver/unit_test build.sh error 2>&1 | tee -a $OUTPUT
copy_file applications/video/camera/unit_test build.sh error 2>&1 | tee -a $OUTPUT

