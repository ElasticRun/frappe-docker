#! /bin/bash
## Script that ensures that nginx only starts once in a container using this image.
ps -f -u nginx | grep -v grep | grep -q -w 'nginx:'
STATUS=$?
if [ $STATUS -eq 0 ]
then
    # Nginx is already running in this docker. Do not try to start again.
    echo "Nginx is already running."
    echo "If you are running web and socketio in same container, this is normal!!"
    sleep 2
    exit 44
else
    echo "Starting nginx in foreground..."
    nginx -g "daemon off;"
fi
