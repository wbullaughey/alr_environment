#!/bin/zsh
SOURCE=$1
TARGET=alire.toml

# must be run from directory where alire.toml.source exists

if [ -f "$SOURCE" ]; then
   echo "$SOURCE exists"
   echo fixing $SOURCE creating $TARGET for $ALR_BUILD_ENVIRONMENT

   case $ALR_BUILD_ENVIRONMENT in

      "desktop")
         sed 's/^%//;/^@/d' $SOURCE > $TARGET
         ;;

      "laptop")
         sed 's/^@//;/^%/d' $SOURCE > $TARGET
         ;;

      "*")
         echo invalid ALR_BUILD_ENVIRONMENT value /$ALR_BUILD_ENVIRONMENT/
         ;;

      "")
         echo missing ALR_BUILD_ENVIRONMENT
         ;;
   esac
else
   echo "$SOURCE does not exist"
fi

