#!/bin/sh
echo "Configuring Bench..."
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
    echo "Updating redis_cache"
    bench config set-common-config -c redis_cache "redis://${CACHE_HOST}"
fi

if [ ! -z ${QUEUE_HOST} ]
then
    echo "Updating redis_queue"
    bench config set-common-config -c redis_queue "redis://${QUEUE_HOST}"
fi

if [ ! -z ${SOCKETIO_HOST} ]
then
    echo "Updating redis_socketio"
    bench config set-common-config -c redis_socketio "redis://${SOCKETIO_HOST}"
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
