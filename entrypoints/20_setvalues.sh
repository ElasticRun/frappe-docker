#!/bin/sh
echo "Configuring Bench..."
cp /home/frappe/docker-bench/sites/common_site_config.json /home/frappe/docker-bench/sites/common_site_config.json.orig
cd ${BENCH_HOME}

if [ ! -z ${DB_HOST} ]
then
    echo "Updating DB Host to ${DB_HOST}"
    bench set-mariadb-host ${DB_HOST}
fi

bench config set-common-config -c root_password ${DB_PASSWORD}

if [ ! -z ${ADMIN_PASSWORD} ]
then
    echo "Setting Admin password"
    bench config set-common-config -c admin_password ${ADMIN_PASSWORD}
fi

if [ ! -z ${CACHE_HOST} ]
then
    echo "Updating redis cache host to ${CACHE_HOST}"
    bench set-redis-cache-host "${CACHE_HOST}"
fi

if [ ! -z ${BIGCACHE_HOST} ]
then
    echo "Updating redis big cache host to ${BIGCACHE_HOST}"
    cat /home/frappe/docker-bench/sites/common_site_config.json | jq '.redis_big_cache = $newVal' --arg newVal "redis://${BIGCACHE_HOST}" > /home/frappe/docker-bench/sites/common_site_config.json.new
    cat /home/frappe/docker-bench/sites/common_site_config.json.new > /home/frappe/docker-bench/sites/common_site_config.json
    rm -f /home/frappe/docker-bench/sites/common_site_config.json.new
fi

if [ ! -z ${QUEUE_HOST} ]
then
    echo "Updating redis_queue host to ${QUEUE_HOST}"
    bench set-redis-queue-host "${QUEUE_HOST}"
fi

if [ ! -z ${SOCKETIO_HOST} ]
then
    echo "Updating redis_socketio host to ${SOCKETIO_HOST}"
    bench set-redis-socketio-host "${SOCKETIO_HOST}"
fi

echo "Bench configured."
