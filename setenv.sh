#! /bin/bash
echo "Setting up default environment variables..."
. /home/frappe/docker-bench/bench.default.env
if [ -f /home/frappe/docker-bench/config/env/bench.env ]
then
  echo "Setting up environment variable overrides..."
  . /home/frappe/docker-bench/config/env/bench.env
fi
