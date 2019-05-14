#!/bin/sh
cd ${BENCH_HOME}
sudo chown -R frappe:frappe ${BENCH_HOME}/sites
echo "run migrations for all sites in the bench"
bench --site all migrate

echo "build JS and CSS artifacts for the bench"
bench build
