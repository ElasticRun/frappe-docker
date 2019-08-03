#!/bin/sh
BENCH_HOME=/home/frappe/${BENCH_NAME}
cd ${BENCH_HOME}
sudo chown -R frappe:frappe ${BENCH_HOME}/sites
if [ ! -d ${BENCH_HOME}/sites/${SITE} -o ! -f ${BENCH_HOME}/sites/${SITE}/site_config.json ]
then
    echo "Deleting existing user, if any..."
    mysql -h ${DB_HOST} -u root -p${DB_PASSWORD} -e "delete from user where user = '${DB_NAME}'; commit; flush privileges;" mysql
    echo "Creating generic user."
    mysql -h ${DB_HOST} -u root -p${DB_PASSWORD} -e \
            "create user \`${DB_NAME}\`@\`%\` identified by '${DB_PASSWORD}'; commit; flush privileges;" mysql
    mysql -h ${DB_HOST} -u root -p${DB_PASSWORD} -e \
            "grant all privileges on \`${DB_NAME}\`.* to \`${DB_NAME}\`@\`%\` with grant option; commit; flush privileges;" mysql
    cp /home/frappe/${BENCH_NAME}/site_config_docker.json /home/frappe/${BENCH_NAME}/sites/${SITE}/site_config.json
    sed s/###DB_NAME###/${DB_NAME}/g /home/frappe/${BENCH_NAME}/sites/${SITE}/site_config.json
    sed s/###DB_PASSWORD###/${DB_PASSWORD}/g /home/frappe/${BENCH_NAME}/sites/${SITE}/site_config.json
    echo "creating new site ${SITE}"
    bench new-site --force --db-name ${DB_NAME} --mariadb-root-username root --admin-password ${ADMIN_PASSWORD} --verbose ${SITE}
    STATUS=$?
    if [ $STATUS -ne 0 ]
    then
        echo "ERROR: An error occurred while setting up new site. Please review logs, correct the error and retry."
        # Removing lock and site_config.json files.
        rm -f ${BENCH_HOME}/sites/${SITE}/*.lock
        rm -f ${BENCH_HOME}/sites/${SITE}/site_config.json
        false
    else
        echo "Providing privileges to new user."
        mysql -h ${DB_HOST} -u root -p${DB_PASSWORD} -e \
            "grant all privileges on \`${DB_NAME}\`.* to \`${DB_NAME}\`@\`%\` identified by '${DB_PASSWORD}' with grant option; commit; flush privileges;" mysql
        mysql -h ${DB_HOST} -u root -p${DB_PASSWORD} -e \
            "delete from user where user = '${DB_NAME}' and host <> '%'; commit; flush privileges;" mysql
        echo "Setting spine configuration to - ${KAFKA_CONFIG}"
        bench set-config --as-dict kafka "'$(echo $KAFKA_CONFIG | tr -d "'" | tr -d "\\" | tr -d "\\n")'"
        # Above command adds \ characters in site_config.json. Remove those using tr.
        mv ${BENCH_HOME}/sites/${SITE}/site_config.json ${BENCH_HOME}/sites/${SITE}/site_config.json_orig
        cat ${BENCH_HOME}/sites/${SITE}/site_config.json_orig |tr -d "\\" | sed s/"\"kafka\": \""/"\"kafka\": "/g | sed s/"\"1\" }\""/"\"1\" }"/g > ${BENCH_HOME}/sites/${SITE}/site_config.json
        bench use ${SITE}
        # echo -n "${SITE}" > ${BENCH_HOME}/sites/currentsite.txt
    fi
fi
