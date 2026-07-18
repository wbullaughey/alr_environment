source /Users/Wayne/.bash_profile
export ARCHITECTURE=macosx
export PROJECT=ada_lib_aunit
export LIB=dynamic
export PROJECT_DIRECTORY=~/Sync/project
export TARGET=$1
#export PATH=/usr/local/gnat_2016/bin:$PATH
export PATH=/opt/gcc-5.2.0/bin:$PATH
#which gcc
#echo $PATH
#echo $USER
#pwd
gprbuild -p                                     \
    -XUser=$USER                                \
    -XARCHITECTURE=macosx                       \
    -XPROJECT_DIRECTORY=$PROJECT_DIRECTORY      \
    -aP$PROJECT_DIRECTORY                       \
    -aP$PROJECT_DIRECTORY/ada_lib
