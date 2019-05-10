#!/bin/sh
export BENCH_NAME=${BENCH_NAME}
export BENCH_HOME=$HOME/$BENCH_NAME
export BENCH_LOG_FILE=$BENCH_HOME/logs/console.log
export SITE=${SITE_NAME:-site1.docker}
CUR_DIR=`pwd`
cd $BENCH_HOME
if [ ! -f ${BENCH_HOME}/sites/apps.txt ]
then
    echo -n 'frappe' > ${BENCH_HOME}/sites/apps.txt
fi
cd ${BENCH_HOME} && bench set-mariadb-host ${DB_HOST} && bench set-config --global root_password ${DB_PASSWORD}
if [ ! -d ${BENCH_HOME}/sites/${SITE} -o ! -f ${BENCH_HOME}/sites/${SITE}/site_config.json ]
then
    # Restore the assets to sites volume that is mounted.
    mv ${BENCH_HOME}/sites-backup mv ${BENCH_HOME}/sites \
    && sudo chown -R frappe:frappe ${BENCH_HOME}/sites/${SITE}
    && bench new-site --force --db-name ${DB_NAME} --mariadb-root-username root --admin-password ${ADMIN_PASSWORD} --verbose ${SITE}
fi
nohup bench start --no-dev >> $BENCH_LOG_FILE 2>&1 &
BENCH_PID=`echo $!`
echo $BENCH_PID > $BENCH_HOME/${BENCH_NAME}.pid
echo "Bench started with Process ID - $BENCH_PID"
read
