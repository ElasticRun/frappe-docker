#!/bin/sh
export BENCH_NAME=${BENCH_NAME}
echo "BENCH_NAME = $BENCH_NAME"
export BENCH_HOME=$HOME/$BENCH_NAME
export BENCH_LOG_FILE=$BENCH_HOME/logs/console.log
export SITE=${SITE_NAME:-site1.docker}
SUCCESS=0
if [ -f $BENCH_HOME/sites/${SITE}/.lock ]
then
  # /bin/sh -c ${BENCH_HOME}/entrypoints/00_entry.sh
  # /bin/sh -c ${BENCH_HOME}/entrypoints/10_mkdirs.sh
  # /bin/sh -c ${BENCH_HOME}/entrypoints/20_setvalues.sh
  echo "Site already setup. Skipping initialization"
else
  sudo touch $BENCH_HOME/sites/${SITE}/.lock
  sudo chown frappe:frappe $BENCH_HOME/sites/${SITE}/.lock

  for file in ${BENCH_HOME}/entrypoints/*.sh
  do
    echo "Executing $file..."
    . "$file"
    if [ $? -ne 0 ]
    then
      SUCCESS=1
      rm -f $BENCH_HOME/sites/${SITE}/.lock
      break
    fi
  done
fi
# Irrespective of site setup as part of startup, bench is always started.
if [ $SUCCESS -eq 0 ]
then
  echo "Starting bench process..."
  /bin/sh -c ./run.sh
fi
exec "$@"
read
