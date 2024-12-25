#!/bin/bash


RANDOM_SLEEP_TIME=100
#((RANDOM % 5 + 1))

echo "Executing run_batch_core.ksh with arguments: $@ for $RANDOM_SLEEP_TIME seconds "


sleep $RANDOM_SLEEP_TIME  # Simulate a long-running process
