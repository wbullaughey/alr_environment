#!/bin/bash
export COMMAND=$*
echo COMMAND $COMMAND

# Check if the required COMMAND are provided
if [ $# -lt 1 ]; then
  echo "Usage: $0 <text_to_search> "
  exit 1
fi
rm concatinated.txt
touch concatinated.txt

for (( ; ; ))
do
   cat concatinated.txt list-ada_lib.txt > merged
   mv merged concatinated.txt
   $COMMAND
   if grep -q "Failed Assertions: 0"  < list-ada_lib.txt; then
     echo "no failed assertions"
     if grep -q "Unexpected Errors: 0"  < list-ada_lib.txt; then
        echo "no unexpected errors"
     else
        echo "unexpected errors"
        exit 1
     fi
   else
     echo "failed assertions"
     exit 1
   fi
done   # Use grep to search for the text in the string

