#!/bin/bash
echo "Starting pod for frappe application"
. ./setenv.sh

echo "BENCH_NAME = $BENCH_NAME"
# Assume this is not a web container.
IS_WEB=1
if [ $# -gt 0 ]
then
  ARG1=$1
  # This check depends on content of supervisor.conf file
  echo $ARG1 | grep -F -q 'docker-bench-web:*'
  IS_WEB=$?
fi

if [ $IS_WEB -eq 0 ]
then
  #Start nginx only if this is a web container.
  sudo nginx -c /home/frappe/${BENCH_NAME}/config/nginx-startup.conf
fi

SUCCESS=0
ls -lart $BENCH_HOME/sites/${SITE}
if [ -f $BENCH_HOME/sites/${SITE}/.lock ]
then
  echo "Site already setup. Performing partial initialization..."
  . ${BENCH_HOME}/entrypoints/20_setvalues.sh
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
  if [ $IS_WEB -eq 0 ]
  then
    echo "Stopping startup nginx. Will be replaced with actual NGinx"
    sudo nginx -s quit
  fi
  echo "Starting supervisor"
  sudo . ./setenv.sh && supervisord --configuration /etc/supervisord.conf
  echo "Starting bench process... Arguments - $@"
  ./run.sh $@
else
  echo "Setup of container failed. Please check logs, correct the error and retry."
  exit 1
fi
