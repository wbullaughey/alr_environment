#!/bin/bash
export TAG=$1
export COMMENT=$2

if [ -z "$TAG" ]; then
   echo "missing tag label"
    exit
fi

if [ -z "$COMMENT" ]; then
   echo "missing comment label"
    exit
fi

git tag -a $TAG -m $COMMENT

# 2. Push the branch first (this pushes all new commits + history)
git push origin master

# 3. Then push the tag
git push origin $TAG
