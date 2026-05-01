#!/bin/sh

(PATH=/export/uclibc_debug/bin;mipsel-uclibc-gnatmake  -aI..  $1.adb)
cp $1 /export/lightraid.cac/wayne

