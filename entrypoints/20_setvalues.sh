#!/bin/sh
echo "Configuring Bench..."
cp /home/frappe/docker-bench/sites/common_site_config.json /home/frappe/docker-bench/sites/common_site_config.json.orig
cd ${BENCH_HOME}
# Hack for ensuring that DB_HOST is correctly setup when using it as ExternalName service in Kubernetes
# export NAMESPACE=${TARGET_NAMESPACE:-default}
# echo "Getting service for DB..."

# # Query Kubernetes API and extract service type.
# export TOKEN=`cat /var/run/secrets/kubernetes.io/serviceaccount/token`
# NEW_DB_HOST=`curl -s https://kubernetes.default.svc/api/v1/namespaces/${NAMESPACE}/services --header "Authorization: Bearer $TOKEN" --insecure | jq '.items[] | select(.metadata.name|test("-db-ntex-com$")) | select(.spec.type|test("^ExternalName$")) | .spec.externalName' | tr -d '"'`
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

# # Fix redis ExternalName services.
# CACHE_HOST=`curl -s https://kubernetes.default.svc/api/v1/namespaces/${NAMESPACE}/services --header "Authorization: Bearer $TOKEN" --insecure | jq '.items[] | select(.metadata.name|test("^er-frappe-redis-cache$")) | select(.spec.type|test("^ExternalName$")) | .spec.externalName + ":" + (.spec.ports[0].targetPort | tostring)' | tr -d '"'`
# QUEUE_HOST=`curl -s https://kubernetes.default.svc/api/v1/namespaces/${NAMESPACE}/services --header "Authorization: Bearer $TOKEN" --insecure | jq '.items[] | select(.metadata.name|test("^er-frappe-redis-queue$")) | select(.spec.type|test("^ExternalName$")) | .spec.externalName + ":" + (.spec.ports[0].targetPort | tostring)' | tr -d '"'`
# SOCKETIO_HOST=`curl -s https://kubernetes.default.svc/api/v1/namespaces/${NAMESPACE}/services --header "Authorization: Bearer $TOKEN" --insecure | jq '.items[] | select(.metadata.name|test("^er-frappe-redis-socketio$")) | select(.spec.type|test("^ExternalName$")) | .spec.externalName + ":" + (.spec.ports[0].targetPort | tostring)' | tr -d '"'`

if [ ! -z ${CACHE_HOST} ]
then
    echo "Updating redis cache host to ${CACHE_HOST}"
    bench set-redis-cache-host "${CACHE_HOST}"
fi

if [ ! -z ${BIGCACHE_HOST} ]
then
    echo "Updating redis big cache host to ${BIGCACHE_HOST}"
    #bench config set-common-config redis_big_cache ${BIGCACHE_HOST}
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

# bench set-config --global file_watcher_port 6787
# bench set-config --global frappe_user frappe
# bench set-config --global gunicorn_workers 4
# bench set-config --global rebase_on_pull false
# bench set-config --global redis_queue redis://frappe-queue-ntex-com:11000
# bench set-config --global redis_socketio redis://frappe-socketio-ntex-com:12000
# bench set-config --global redis_cache redis://frappe-cache-ntex-com:13000
# bench set-config --global restart_supervisor_on_update false
# bench set-config --global serve_default_site true
# bench set-config --global shallow_clone true
# bench set-config --global socketio_port 9000
# bench set-config --global webserver_port 8000

echo "Bench configured."
