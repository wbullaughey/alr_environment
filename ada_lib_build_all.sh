#!/bin/zsh
function build() {
echo 1 $1 2 $2
   DIRECTOR=$1
   PROGRAM=$2
   echo building $1 in $2
   pwd
   pushd $1
   pwd
   ./build.sh execute $2
   popd
   pwd
}

#build \. alr_environment
#build aunit aunit
#build ada_lib/ada_lib_options ada_lib_options
#build ada_lib/ada_lib_base ada_lib_base
#build vendor/git_hub.com/gnoga gnoga
#build gnoga_lib gnoga_lib
#build ada_lib ada_lib
#build applications/video/library video_lib
build applications/video/camera/library camera_lib
