#!/bin/bash
SCRIPT_PATH=$(realpath "$0")
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")
FILE=$SCRIPT_DIR/sema


if [ "$1" == "--help" ]; then
    echo "Usage: sema_take.sh NumberSuffix"
    echo "Script will test semaphore and if it's not taken"
    echo "it will take it for NumberSuffix time"
    echo "Suffix: min|hour|hours"
    echo "Example: sema_take.sh 30min"
    echo "Example: sema_take.sh 2hours"
    echo "[Note]it's possible to take semaphore with --force"

    exit 2
fi

if [ "$2"  == "--force" ]; then
    SEMA_FORCE=1
    if sudo -n true 2>/dev/null; then
        echo "User has sudo rights."
    else
        echo "User does not have sudo rights."
        exit 1
    fi
else
    SEMA_FORCE=0

    SEMA_TEST=$($SCRIPT_DIR/sema_test.sh)
    if [ $? -eq 255 ]; then
        echo $SEMA_TEST
        exit 1
    fi

fi

if [ ! -f "$FILE" ]; then
    touch "$FILE"
    chmod o+rw "$FILE"
fi

DURATION=$1

# Regex pattern to match duration (e.g., 1min, 2h, 30s)
DURATION_PATTERN="^[0-9]+(min|hour|hours|day)$"
DATE_PATTERN='+%d.%m.%Y %H:%M:%S'

CURRENT_DATE=$(date "$DATE_PATTERN")
CURRENT_TIME_IN_SEC=$(date +%s)

# Check if input matches duration pattern
if [[ $DURATION =~ $DURATION_PATTERN ]]; then
    # It's a duration, calculate the time from now
    RELEASE_DATE=$(date -d "$DURATION" "$DATE_PATTERN")
    RELEASE_DATE_AT=$(date -d "$DURATION" +"%y%m%d%H%M")
    RELEASE_TIME_IN_SEC=$(date -d "$DURATION" '+%s')
else
    echo "Wrong duration format, use: $DURATION_PATTERN"
    exit 1
fi

if [ -f "$FILE" ]; then
    SEMA_AT_JOB_NUMBER=$(sed -n '7p' $FILE)
    atrm $SEMA_AT_JOB_NUMBER  > /dev/null 2>&1
fi


echo $USER > $FILE
echo $CURRENT_DATE  >> $FILE
echo $CURRENT_TIME_IN_SEC  >> $FILE
echo $RELEASE_DATE  >> $FILE
echo $RELEASE_TIME_IN_SEC  >> $FILE
echo $SSH_CLIENT | awk '{ print $1}' >> $FILE # SEMA_USER_IP


echo "You requested semaphore: " $1
echo "Time now               : " $CURRENT_DATE
echo "You got semaphore till : " $RELEASE_DATE

output=$(echo 'wall -g $USER "$USER semaphore expired. Use sema_take 10min"'  | at -t $RELEASE_DATE_AT 2>&1 | grep -v "warning:"| grep -oP '(?<=job )\d+')
echo "$output" >> $FILE

$SCRIPT_DIR/sema_log.sh $@
