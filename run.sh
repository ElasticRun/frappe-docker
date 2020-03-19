#! /bin/bash
BENCH_HOME=/home/frappe/${BENCH_NAME}
cd ${BENCH_HOME}
SUCCESS=0

export GUNI_WORKER_CONNECTIONS=${GUNI_WORKER_CONNECTIONS:-200}
export GUNI_WORKERS=${GUNI_WORKERS:-4}
# TODO Find a way to keep this check in single common place.
# Assume this is not a web container.
# [ajit.pendse 19-03-2020] nginx startup added to supervisor configuration. 
# This check is no longer needed.
# IS_WEB=1
# if [ $# -gt 0 ]
# then
#   ARG1=$1
#   # This check depends on content of supervisor.conf file
#   echo $ARG1 | grep -F -q 'docker-bench-web:*'
#   IS_WEB=$?
#   if [ ${IS_WEB} -ne 0 ]
#   then
#     echo $ARG1 | grep -F -q 'docker-bench-socketio:*'
#     IS_WEB=$?
#   fi
# fi

# if [ $IS_WEB -eq 0 ]
# then
#     #Start nginx only if this is a web container.
#     sudo nginx
# fi
# Check if specific worker is specified then start bench with args
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
# TAIL_CMD="tail -F /home/frappe/docker-bench/logs/access.log -F /home/frappe/docker-bench/logs/frappe.log"
# for file in `ls /home/frappe/docker-bench/logs/*.error.log`
# do
#     TAIL_CMD="$TAIL_CMD -F $file"
# done
exec $TAIL_CMD
