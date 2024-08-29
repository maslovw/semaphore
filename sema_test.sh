#!/bin/bash

SCRIPT_PATH=$(realpath "$0")
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")
FILE_PATH="$SCRIPT_DIR/sema"

# Enum for exit codes
EXIT_SUCCESS=0
EXIT_SEMA_TAKEN_BY_OTHER=255
EXIT_SEMA_TAKEN_BY_USER=1

# Argument parsing
SEMA_VERBOSE=0
while getopts ":v" opt; do
    case $opt in
        v)
            SEMA_VERBOSE=1
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit $EXIT_SUCCESS
            ;;
    esac
done

# Determine if the script is running in an interactive shell
if [ -t 0 ]; then
    SEMA_VERBOSE=1
fi

# Check if the semaphore file exists
if [ ! -f "$FILE_PATH" ]; then
    [ "$SEMA_VERBOSE" -ne 0 ] && echo "Semaphore is not taken"
    #touch "$FILE_PATH"
    #chown "$USER:elite" "$FILE_PATH"
    exit $EXIT_SUCCESS
fi

CURRENT_TIME_SEC=$(date +%s)
CURRENT_USERNAME=$USER
CURRENT_USER_IP=$(echo $SSH_CLIENT | awk '{ print $1}')

# Read semaphore details from the file
SEMA_USER=$(sed -n '1p' "$FILE_PATH")
SEMA_CURRENT_DATE=$(sed -n '2p' "$FILE_PATH")
SEMA_CURRENT_TIME_IN_SEC=$(sed -n '3p' "$FILE_PATH")
SEMA_RELEASE_DATE=$(sed -n '4p' "$FILE_PATH")
SEMA_RELEASE_TIME_IN_SEC=$(sed -n '5p' "$FILE_PATH")
SEMA_USER_IP=$(sed -n '6p' "$FILE_PATH")
SEMA_AT_JOB_NUMBER=$(sed -n '7p' "$FILE_PATH")

# Compare the username from the file with the current system username
if [ "$SEMA_USER" != "$CURRENT_USERNAME" ]; then
    if [ "$SEMA_RELEASE_TIME_IN_SEC" -le "$CURRENT_TIME_SEC" ]; then
        [ "$SEMA_VERBOSE" -ne 0 ] && echo "Semaphore is not taken"
        exit $EXIT_SUCCESS # Semaphore is not taken
    else
        echo "$SEMA_USER semaphore is active until $SEMA_RELEASE_DATE"
        exit $EXIT_SEMA_TAKEN_BY_OTHER # Semaphore is taken by another user
    fi
else
    if [ "$SEMA_RELEASE_TIME_IN_SEC" -le "$CURRENT_TIME_SEC" ]; then
        [ "$SEMA_VERBOSE" -ne 0 ] && echo "Your semaphore is released"
        exit $EXIT_SUCCESS # Semaphore is not taken
    else
        [ "$SEMA_VERBOSE" -ne 0 ] && echo "Your semaphore is still active until $SEMA_RELEASE_DATE"
        exit $EXIT_SEMA_TAKEN_BY_USER # Semaphore is taken by the user
    fi
fi
