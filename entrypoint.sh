#!/bin/sh
export BENCH_NAME=${BENCH_NAME}
echo "BENCH_NAME = $BENCH_NAME"
export BENCH_HOME=$HOME/$BENCH_NAME
export BENCH_LOG_FILE=$BENCH_HOME/logs/console.log
export SITE=${SITE_NAME:-site1.docker}
if [ -f $BENCH_HOME/sites/${SITE}.lock ]
then
  echo "Site already setup. Skipping initialization"
else
  for file in ${BENCH_HOME}/entrypoints/*.sh
  do
    echo "Executing $file..."
    /bin/sh -c "$file"
  done
  sudo touch $BENCH_HOME/sites/${SITE}.lock
  sudo chown frappe:frappe $BENCH_HOME/sites/${SITE}.lock
fi
# Irrespective of site setup as part of startup, bench is always started.
/bin/sh -c ./start.sh
exec "$@"
read
