#!/bin/sh
echo "set bench values"
cd ${BENCH_HOME}
bench set-mariadb-host ${DB_HOST}

bench set-config --global root_password ${DB_PASSWORD}
