#!/bin/sh
echo "set bench values"
cd ${BENCH_HOME}
bench set-mariadb-host ${DB_HOST}

bench set-config --global root_password ${DB_PASSWORD}
bench set-config --global file_watcher_port 6787
bench set-config --global frappe_user frappe
bench set-config --global gunicorn_workers 4
bench set-config --global rebase_on_pull false
bench set-config --global redis_cache redis://frappe.cache.ntex.com:13000
bench set-config --global redis_cache redis_queue redis://frappe.queue.ntex.com:11000
bench set-config --global redis_cache redis_socketio redis://redis-socketio:12000
bench set-config --global redis_cache restart_supervisor_on_update false
bench set-config --global redis_cache serve_default_site true
bench set-config --global redis_cache shallow_clone true
bench set-config --global redis_cache socketio_port 9000
bench set-config --global redis_cache webserver_port 8000
if [ "X${ADMIN_PASSWORD}" != "X" ]
then
    echo "Setting Admin password"
    bench set-config --global redis_cache admin_password ${ADMIN_PASSWORD}
fi
