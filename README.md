# Semaphore Management Scripts

## Overview

This package contains two scripts, `sema_take.sh` and `sema_test.sh`, designed to manage a semaphore mechanism on a Unix/Linux system. Semaphores in this context are used as a signaling mechanism to control access to a shared resource by multiple processes. Specifically, these scripts facilitate the reservation of a semaphore for a specified duration, allowing serialized access to a resource.

## `sema_take.sh`

### Purpose

The `sema_take.sh` script is used to acquire a semaphore for a specified duration. It ensures that the semaphore is not already taken before acquiring it. If the semaphore is already in use, the script prevents overwriting unless forced by the user.

### Usage

```bash
./sema_take.sh [Duration] [--force]
```

- `Duration`: Specifies how long the semaphore should be reserved. It must follow the format `[number](min|hour|hours|day)`, e.g., `30min` or `2hours`.
- `--force`: Optional flag to force the acquisition of the semaphore, even if it's already taken. Requires sudo rights.

#### Examples

```bash
./sema_take.sh 30min
./sema_take.sh 1hour --force
```

### Notes

- The script checks for sudo rights if the `--force` option is used.
- It utilizes `at` commands to schedule a notification when the semaphore's duration expires.

## `sema_test.sh`

### Purpose

The `sema_test.sh` script checks the status of the semaphore. It determines whether the semaphore is currently taken and, if so, by whom and until when it is reserved.

### Usage

```bash
./sema_test.sh
```

```bash

SEMA_TEST=$(./sema_test.sh)

if [ $? -eq 0 ]; then
    export PATH=$PATH:/path/to/tools
else
    echo $SEMA_TEST
    echo "Functionality is limited"
fi
```

This script does not require any arguments. It reads the semaphore status from a shared file and provides information about the current state of the semaphore.

### Output

The script outputs one of the following statuses:

- `Semaphore is not taken`: Indicates the semaphore is currently available for reservation.
- `[username] semaphore is active until [date]`: Shows that the semaphore is taken by a specific user until the given date and time.
- `Your semaphore is released`: Indicates the user's previously reserved semaphore has expired.
- `Your semaphore is still active until [date]`: Informs the user that their semaphore reservation is still valid.

- exit return value is 0 if you can take semaphore
- exit return value is 1 if you can not take semaphore


## Common Features

- **File-based Semaphore Management**: Both scripts use a file named `sema` located in the same directory as the scripts to manage semaphore status. This file records the current state, including the owner, acquisition time, and release time of the semaphore.
- **Duration Handling**: The `sema_take.sh` script supports multiple units for duration, including minutes, hours, and days, to flexibly manage resource access time.

## Prerequisites

- Linux/Unix environment
- `at` and `sudo` commands for certain operations: `apt install at`
- Permission to execute the scripts and modify the `sema` file
- group named `sema` and all users should be part of the group to be able to take semaphore

---

