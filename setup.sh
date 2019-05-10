#!/bin/sh
# setup bench and yarn required for frappe
BASE_BENCH_DIR=/home/frappe/frappe-bench
TARGET_BENCH_DIR=/home/frappe/docker-bench
# echo "Installing Bench..."
# cd /home/frappe
# sudo pip install -e bench-repo
# echo "Bench Installed."
# sudo rm -rf ~/.cache/pip
if [[ -d ${TARGET_BENCH_DIR} ]]; then
    cd ${TARGET_BENCH_DIR}
    bench console << EOF
frappe.get_all("User", limit_page_length=1)
EOF
    STATUS=$?
    if [[ $STATUS -ne 0 ]] ; then
        echo "Bench is not initialized. Setting up new bench instance..."
        cd /home/frappe
        bench init docker-bench --ignore-exist --skip-redis-config-generation --no-procfile --verbose
        echo "Setting up default configurations..."
        cp -f ${BASE_BENCH_DIR}/start-bench.sh ${TARGET_BENCH_DIR}/start-bench.sh
        cp -f ${BASE_BENCH_DIR}/Procfile_docker ${TARGET_BENCH_DIR}/Procfile
        cp -f ${BASE_BENCH_DIR}/common_site_config_docker.json ${TARGET_BENCH_DIR}/sites/common_site_config.json
        cd ${TARGET_BENCH_DIR} && bench set-mariadb-host $DB_HOST && bench set-config -g root_password $DB_PASSWORD
        echo "Default configurations completed. Setting up site..."
        bench new-site --db-name dockerdb --mariadb-root-username root --mariadb-root-password $DB_PASSWORD --admin-password $ADMIN_PASSWORD --verbose frappesite.docker
        echo "Site setup successfully"
    fi
fi
echo "Trying to start docker-bench..."
${TARGET_BENCH_DIR}/start-bench.sh
read
