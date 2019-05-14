#!/bin/sh
cd ${BENCH_HOME}
sudo chown -R frappe:frappe ${BENCH_HOME}/sites
if [ ! -d ${BENCH_HOME}/sites/${SITE} -o ! -f ${BENCH_HOME}/sites/${SITE}/site_config.json ]
then
    echo "creating new site ${SITE}"
    bench new-site --force --db-name ${DB_NAME} --mariadb-root-username root --admin-password ${ADMIN_PASSWORD} --verbose ${SITE}
    echo -n "${SITE}" > ${BENCH_HOME}/sites/currentsite.txt
fi
