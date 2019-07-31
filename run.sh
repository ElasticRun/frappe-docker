#! /bin/sh
BENCH_HOME=/home/frappe/${BENCH_NAME}
cd ${BENCH_HOME}
sudo nginx
nohup bench start --no-dev >> $BENCH_LOG_FILE 2>&1 &
BENCH_PID=`echo $!`
echo $BENCH_PID > $BENCH_HOME/${BENCH_NAME}.pid
echo "Bench started with Process ID - ${BENCH_PID}"
ps -eaf | grep ${BENCH_PID}
echo "run $@"
tail -f /home/frappe/docker-bench/logs/console.log -f /home/frappe/docker-bench/logs/access.log -f /home/frappe/docker-bench/logs/bench.log
