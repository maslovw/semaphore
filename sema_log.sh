#!/bin/bash
SCRIPT_PATH=$(realpath "$0")
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")
SEMA_FILE=$SCRIPT_DIR/sema
FILE=$SCRIPT_DIR/sema.log

# Check if the file exists
if [ ! -f "$FILE" ]; then
    touch $FILE
    chown $USER:elite $FILE
    exit 0
fi
echo $USER: $@ >> $FILE
cat $SEMA_FILE >> $FILE
echo "-----------------------" >> $FILE
