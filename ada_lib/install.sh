#!/bin/sh
# $1 = architecture: intel | ppm | lightender
# $2 = target: debug | release
echo running $0 at `pwd`

export ARCHITECTURE=$1
export TARGET=$2
shift 2
export LIB=static

while [ "$1" != "" ]; do    # use this to add extra defines like EDFA1
    echo define $1
        export $1
        shift 1
done

export GPR_OPTIONS=--uninstall
./local_build.sh gprinstall
export GPR_OPTIONS=-v
./local_build.sh gprinstall
