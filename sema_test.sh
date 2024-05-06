#!/bin/bash

SCRIPT_PATH=$(realpath "$0")
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")
# Path to the file containing the release time
FILE_PATH=$SCRIPT_DIR/sema
# Check if the file exists
if [ ! -f "$FILE_PATH" ]; then
    echo "Semaphore is not taken"
    touch $FILE_PATH
    chown $USER:elite $FILE_PATH
    exit 0
fi

# Convert release time and current time to seconds since the epoch for comparison
CURRENT_TIME_SEC=$(date +%s)

# Get the current system username
CURRENT_USERNAME=$USER

SEMA_USER=$(sed -n '1p' $FILE_PATH)
SEMA_CURRENT_DATE=$(sed -n '2p' $FILE_PATH)
SEMA_CURRENT_TIME_IN_SEC=$(sed -n '3p' $FILE_PATH)
SEMA_RELEASE_DATE=$(sed -n '4p' $FILE_PATH)
SEMA_RELEASE_TIME_IN_SEC=$(sed -n '5p' $FILE_PATH)


# Compare the username from the file with the current system username
if [ "$SEMA_USER" != "$CURRENT_USERNAME" ]; then
    if [ "$SEMA_RELEASE_TIME_IN_SEC" -le "$CURRENT_TIME_SEC" ]; then
        echo "Semaphore is not taken"
        exit 0
    else
        echo "$SEMA_USER semaphore is active until $SEMA_RELEASE_DATE"
        exit 1
    fi
else
    if [ "$SEMA_RELEASE_TIME_IN_SEC" -le "$CURRENT_TIME_SEC" ]; then
        echo "Your semaphore is released"
        exit 0
    else
        echo "Your semaphore is still active until $SEMA_RELEASE_DATE"
        exit 0
    fi
fi

