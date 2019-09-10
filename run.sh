#! /bin/sh
BENCH_HOME=/home/frappe/${BENCH_NAME}
cd ${BENCH_HOME}
SUCCESS=0
echo "Looking for boot_scripts"
if [ -d $BENCH_HOME/boot_scripts ]
then
    for file in ${BENCH_HOME}/boot_scripts/*.sh
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
    echo "One of the boot scripts failed. Exiting container"
    exit 1
fi
sudo nginx

# Check if specific worker is specified then start bench with args
if [ $# -ne 0 ]
then
    echo "Starting bench with args - $@"
    nohup bench start --no-dev $@ >> $BENCH_LOG_FILE 2>&1 &
    BENCH_PID=`echo $!`
else
    nohup bench start --no-dev >> $BENCH_LOG_FILE 2>&1 &
    BENCH_PID=`echo $!`
fi

echo $BENCH_PID > $BENCH_HOME/${BENCH_NAME}.pid
echo "Bench started with Process ID - ${BENCH_PID}"
ps -eaf | grep ${BENCH_PID}
echo "run $@"
tail -F /home/frappe/docker-bench/logs/console.log -F /home/frappe/docker-bench/logs/access.log \
    -F /home/frappe/docker-bench/logs/bench.log -F /home/frappe/docker-bench/logs/frappe.log
