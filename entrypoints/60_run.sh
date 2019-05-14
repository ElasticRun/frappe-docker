#! /bin/sh
cd ${BENCH_HOME}
nohup bench start --no-dev >> $BENCH_LOG_FILE 2>&1 &
BENCH_PID=`echo $!`
echo $BENCH_PID > $BENCH_HOME/${BENCH_NAME}.pid
echo "Bench started with Process ID - $BENCH_PID"
echo "run $@"
