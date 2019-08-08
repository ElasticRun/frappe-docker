#!/bin/sh
export SITE=${SITE_NAME:-site1.docker}
# sudo cp -R /home/frappe/sites-backup/.build ${BENCH_HOME}/sites/ \
#      && sudo cp -R /home/frappe/sites-backup/* ${BENCH_HOME}/sites/ \
#      && sudo ln -s ${BENCH_HOME}/apps/frappe/frappe/public ${BENCH_HOME}/sites/assets/frappe \
#      && sudo rm -rf /home/frappe/sites-backup
if [ -d ${BENCH_HOME}/sites/common_site_config.json ]
then
    sudo rm -rf ${BENCH_HOME}/sites/common_site_config.json
fi

if [ -d ${BENCH_HOME}/sites/apps.txt ]
then
    sudo rm -rf ${BENCH_HOME}/sites/apps.txt
fi

if [ -d ${BENCH_HOME}/sites/currentsite.txt ]
then
    sudo rm -rf ${BENCH_HOME}/sites/currentsite.txt
fi

if [ -d ${BENCH_HOME}/sites/common_site_config.json ]
then
    sudo rm -rf ${BENCH_HOME}/sites/common_site_config.json
fi

# No longer required as sites directory is now within the image.
#cp /home/frappe/common_site_config_docker.json ${BENCH_HOME}/sites/common_site_config.json
sudo chown -R frappe:frappe ${BENCH_HOME}/sites ${BENCH_HOME}/logs
if [ ! -f ${BENCH_HOME}/sites/apps.txt ]
then
    echo -n 'frappe' > ${BENCH_HOME}/sites/apps.txt
fi

if [ ! -f ${BENCH_HOME}/sites/common_site_config.json ]
then
    cp /home/frappe/docker-bench/common_site_config_docker.json ${BENCH_HOME}/sites/common_site_config.json
fi
