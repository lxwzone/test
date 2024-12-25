#!/bin/bash

#!/bin/bash

# Command to execute
COMMAND="./run_batch.ksh arg1"



# Loop 1000 times
for i in {1..200}; do
    echo "Executing instance $i"
    ./run_batch.ksh arg "$i" &
done

#Test 1 - trigger 200 executions at the same time, now check with 'ps -ef | grep run_batch_core.ksh' to make sure the number of executions is less than the limit
#Test 2 - log fils get cleaned up regularly 
#Test 3 - if running run_batch.ksh , then kill it this parent process, the child process gets killed as well


