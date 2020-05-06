#! /bin/bash
BENCH_HOME=/home/frappe/${BENCH_NAME}
cd ${BENCH_HOME}
SUCCESS=0

export GUNI_WORKER_CONNECTIONS=${GUNI_WORKER_CONNECTIONS:-200}
export GUNI_WORKERS=${GUNI_WORKERS:-4}
# Check if specific worker is specified - then start bench with args
if [ $# -ne 0 ]
then
    echo "Starting bench with args - $@"
    sudo supervisorctl start $@ >> $BENCH_LOG_FILE 2>&1 &
else
    # If there are no inputs (i.e. start all processes), check if spine processes can be started.
    echo "Checking if spine is installed"
    SPINE_EXISTS=`ls /home/frappe/docker-bench/apps | grep -w 'spine'`
    echo "Spine Exists ? - ${SPINE_EXISTS}"
    if [ "X${SPINE_EXISTS}" == "X" ]
    then
      echo "Setting non-spine args to ${NONSPINE_ARGS}"
      ARGS=${NONSPINE_ARGS}
    fi
    if [ "X${ARGS}" != "X" ]
    then
        sudo supervisorctl start ${ARGS} >> $BENCH_LOG_FILE 2>&1 &
    else
        sudo supervisorctl start all >> $BENCH_LOG_FILE 2>&1 &
    fi
fi
echo "Started gunicorn server with ${GUNI_WORKERS} workers and ${GUNI_WORKER_CONNECTIONS} connections per worker."

#ps -eaf | grep ${BENCH_PID}
echo "run $@"

echo "Looking for postboot_scripts"
if [ -d $BENCH_HOME/postboot_scripts ]
then
    for file in ${BENCH_HOME}/postboot_scripts/*.sh
    do
        echo "Executing $file..."
        . "$file"
        if [ $? -ne 0 ]
        then
            echo "$file execution failed. Exiting..."
            SUCCESS=1
            break
        fi
    done
fi
if [ $SUCCESS -ne 0 ]
then
    echo "One of the post boot scripts failed... Please check logs for more information"
fi
TAIL_CMD="xtail /home/frappe/docker-bench/logs/*.log"

exec $TAIL_CMD
