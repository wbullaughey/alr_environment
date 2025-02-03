#!/bin/zsh
export VERBOSE=$1
echo VERBOSE $VERBOSE
export RELATIVE_PATH=Project/git/alr/alr_environment
export SOURCE=/Users/wayne/$RELATIVE_PATH
export DESTINATION=/Volumes/wayne/$RELATIVE_PATH
export OUTPUT=rsync.txt

if [ -z "$VERBOSE" ]; then # not verbose
   export OPTIONS="-lptvq"
else                       # verbose
   export OPTIONS=-lptvv
fi

echo OPTIONS $OPTIONS

function copy_file {
   if [ -n "$VERBOSE" ]; then
      echo "source: $SOURCE" file: $1
      echo "rsync file $OPTIONS $SOURCE/$1 $DESTINATION"
   fi
   if [[ -e $SOURCE/$1 ]]; then
      rsync $OPTIONS $SOURCE/$1 $DESTINATION/$1
   else
      echo "$SOURCE/$1 does not exist"
   fi
}

function copy_directory {
   if [ -n "$VERBOSE" ]; then
      echo "source: $SOURCE directory: $1"
      echo "rsync directory $OPTIONS $SOURCE/$1/src/* $DESTINATION/$1/src"
   fi
   rsync $OPTIONS $SOURCE/$1/*.gpr $DESTINATION/$1
   rsync $OPTIONS $SOURCE/$1/src/* $DESTINATION/$1/src
   if [ -d "$OPTIONS $SOURCE/$1/config" ]; then
      rsync $OPTIONS $SOURCE/$1/config/* $DESTINATION/$1/config
   fi
   copy_file $1/alire.toml
   copy_file $1/project_paths.cfg
}

echo "rsync source $SOURCE destination $DESTINATION" 2>&1 | tee $OUTPUT

copy_directory "" 2>&1 | tee -a $OUTPUT
copy_directory "ada_lib" 2>&1 | tee -a $OUTPUT
copy_directory "ada_lib/ada_lib_gnoga" 2>&1 | tee -a $OUTPUT
copy_directory "ada_lib/ada_lib_tests" 2>&1 | tee -a $OUTPUT
copy_directory "aunit" 2>&1 | tee -a $OUTPUT
copy_directory "aunit/ada_lib" 2>&1 | tee -a $OUTPUT
#copy_directory "vendor/github.com/gnoga" 2>&1 | tee -a $OUTPUT
##copy_directory "vendor/github.com/gnoga-forked" 2>&1 | tee -a $OUTPUT
#copy_directory "video/camera" 2>&1 | tee -a $OUTPUT
#copy_directory "video/camera/lib" 2>&1 | tee -a $OUTPUT
##copy_directory "video/camera/lib/unit_test" 2>&1 | tee -a $OUTPUT
#copy_directory "video/camera/test_lib" 2>&1 | tee -a $OUTPUT
#copy_directory "video/camera/unit_test" 2>&1 | tee -a $OUTPUT
#copy_directory "video/camera/driver" 2>&1 | tee -a $OUTPUT
#copy_directory "video/camera/driver/unit_test" 2>&1 | tee -a $OUTPUT
#copy_directory "video/lib" 2>&1 | tee -a $OUTPUT
#copy_directory "video/lib/video_aunit" 2>&1 | tee -a $OUTPUT

copy_file remote_build.sh 2>&1 | tee -a $OUTPUT
copy_file ada_lib/ada_lib_tests/build.sh 2>&1 | tee -a $OUTPUT
#copy_file video/camera/build.sh 2>&1 | tee -a $OUTPUT
#copy_file video/camera/driver/build.sh 2>&1 | tee -a $OUTPUT
#copy_file video/camera/driver/unit_test/build.sh 2>&1 | tee -a $OUTPUT
#copy_file video/camera/unit_test/build.sh 2>&1 | tee -a $OUTPUT

