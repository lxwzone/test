#!/bin/bash

#!/bin/bash

# Command to execute
COMMAND="./run_batch.ksh arg1"

# Start a new process group for the parent script
set -m

# Loop 1000 times
for i in {1..1000}; do
    echo "Executing instance $i"
    ./run_batch.ksh arg "$i" &
done
