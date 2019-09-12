#!/bin/bash
echo "Starting pod for frappe application"
export BENCH_NAME=${BENCH_NAME}
echo "BENCH_NAME = $BENCH_NAME"
export BENCH_HOME=$HOME/$BENCH_NAME
export BENCH_LOG_FILE=$BENCH_HOME/logs/console.log
export SITE=${SITE_NAME:-site1.docker}
sudo nginx -c /home/frappe/${BENCH_NAME}/config/nginx-startup.conf
SUCCESS=0
ls -lart $BENCH_HOME/sites/${SITE}
if [ -f $BENCH_HOME/sites/${SITE}/.lock ]
then
  # /bin/sh -c ${BENCH_HOME}/entrypoints/00_entry.sh
  # /bin/sh -c ${BENCH_HOME}/entrypoints/10_mkdirs.sh
  # /bin/sh -c ${BENCH_HOME}/entrypoints/20_setvalues.sh
  echo "Site already setup. Skipping initialization"
else
  echo "Setting up new site ${SITE}"
  if [ ! -d $BENCH_HOME/sites/${SITE} ]
  then
    mkdir -p $BENCH_HOME/sites/${SITE}
  fi
  sudo touch $BENCH_HOME/sites/${SITE}/.lock
  sudo chown frappe:frappe $BENCH_HOME/sites/${SITE}/.lock

  for file in ${BENCH_HOME}/entrypoints/*.sh
  do
    echo "Executing $file..."
    . "$file"
    if [ $? -ne 0 ]
    then
      echo "$file execution failed. Exiting..."
      SUCCESS=1
      rm -f $BENCH_HOME/sites/${SITE}/.lock
      break
    fi
  done
fi

echo "Looking for boot_scripts"
if [ -d $BENCH_HOME/boot_scripts ]
then
    for file in ${BENCH_HOME}/boot_scripts/*.sh
    do
        echo "Executing $file..."
        . "$file"
        if [ $? -ne 0 ]
        then
            echo "$file execution failed. Exiting..."
            SUCCESS=1
            break
        fi
    done
fi
if [ $SUCCESS -ne 0 ]
then
    echo "One of the boot scripts failed. Exiting container"
    exit 1
fi
# Irrespective of site setup as part of startup, bench is always started.
if [ $SUCCESS -eq 0 ]
then
  echo "Stopping startup nginx. Will be replaced with actual NGinx"
  sudo nginx -s quit
  echo "Starting supervisor"
  sudo supervisord --configuration /etc/supervisor/supervisord.conf
  echo "Starting bench process..."
  /bin/sh -c ./run.sh $@
else
  echo "Setup of container failed. Please check logs, correct the error and retry."
  exit 1
fi
