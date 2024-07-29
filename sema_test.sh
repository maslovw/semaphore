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

if [ -t 0 ]; then
    #echo "interactive"
    SEMA_VERBOSE=1
else
    #echo "non-interactive"
    SEMA_VERBOSE=0
fi

# Convert release time and current time to seconds since the epoch for comparison
CURRENT_TIME_SEC=$(date +%s)

# Get the current system username
CURRENT_USERNAME=$USER
CURRENT_USER_IP=$(echo $SSH_CLIENT | awk '{ print $1}')

SEMA_USER=$(sed -n '1p' $FILE_PATH)
SEMA_CURRENT_DATE=$(sed -n '2p' $FILE_PATH)
SEMA_CURRENT_TIME_IN_SEC=$(sed -n '3p' $FILE_PATH)
SEMA_RELEASE_DATE=$(sed -n '4p' $FILE_PATH)
SEMA_RELEASE_TIME_IN_SEC=$(sed -n '5p' $FILE_PATH)
SEMA_USER_IP=$(sed -n '6p' $FILE_PATH)
SEMA_AT_JOB_NUMBER=$(sed -n '7p' $FILE_PATH)


# Compare the username from the file with the current system username
if [ "$SEMA_USER" != "$CURRENT_USERNAME" ]; then
    if [ "$SEMA_RELEASE_TIME_IN_SEC" -le "$CURRENT_TIME_SEC" ]; then
        if [ "$SEMA_VERBOSE" != 0 ]; then
            echo "Semaphore is not taken"
        fi
        exit 0 # semaphore is not taken
    else
        echo "$SEMA_USER semaphore is active until $SEMA_RELEASE_DATE"
        exit 255 # semaphore is taken by another USER
    fi
else
    if [ "$SEMA_RELEASE_TIME_IN_SEC" -le "$CURRENT_TIME_SEC" ]; then
        if [ "$SEMA_VERBOSE" != 0 ]; then
            echo "Your semaphore is released"
        fi
        exit 0 # semaphore is not taken
    else
        if [ "$SEMA_VERBOSE" != 0 ]; then
            echo "Your semaphore is still active until $SEMA_RELEASE_DATE $SEMA_VERBOSE"
        fi
        exit 1 # semaphore is taken by the USER
    fi
fi

