#! /bin/bash
#. /home/frappe/docker-bench/setenv.sh
bench list-apps | grep -q latte
LATTE_EXISTS=$?
echo "Gunicorn Workers - ${GUNI_WORKERS} & Worker Connections - ${GUNI_WORKER_CONNECTIONS}"
if [ $LATTE_EXISTS -eq 0 ]
then
    #Latte exists.
    echo "Starting latte web worker"
    bench serve --noreload --port 8002 --workers ${GUNI_WORKERS} --worker-connections ${GUNI_WORKER_CONNECTIONS}
else
    #Latte not installed
    echo "Starting gunicorn web worker"
    cd /home/frappe/docker-bench/sites && /home/frappe/docker-bench/env/bin/gunicorn -b 0.0.0.0:8002 -t 120 frappe.app:application --workers ${GUNI_WORKERS} --worker-connections ${GUNI_WORKER_CONNECTIONS} -k gevent --access-logfile /home/frappe/docker-bench/logs/access.log --access-logformat  '{"remote_ip":"%%(h)s","request_id":"%%({X-Request-Id}i)s","response_code":%%(s)s,"request_method":"%%(m)s","request_path":"%%(U)s","request_querystring":"%%(q)s","request_timetaken":%%(D)s,"response_length":%%(B)s}'
fi
