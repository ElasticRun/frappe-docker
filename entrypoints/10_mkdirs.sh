#!/bin/sh
export SITE=${SITE_NAME:-site1.docker}
# sudo cp -R /home/frappe/sites-backup/.build ${BENCH_HOME}/sites/ \
#      && sudo cp -R /home/frappe/sites-backup/* ${BENCH_HOME}/sites/ \
#      && sudo ln -s ${BENCH_HOME}/apps/frappe/frappe/public ${BENCH_HOME}/sites/assets/frappe \
#      && sudo rm -rf /home/frappe/sites-backup

sudo chown -R frappe:frappe ${BENCH_HOME}/sites/${SITE} ${BENCH_HOME}/logs
if [ ! -f ${BENCH_HOME}/sites/apps.txt ]
then
    echo -n 'frappe' > ${BENCH_HOME}/sites/apps.txt
fi
