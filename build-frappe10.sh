#! /bin/bash
TAG=$1
# Uses default frappe and bench master branches from github to build the docker image. Use own URLs to override.
docker build -f Dockerfile_frappe10 --build-arg KAFKA_CONFIG=${KAFKA_CONFIG}\
  --build-arg GIT_FRAPPE_URL=github.com/frappe/frappe.git --build-arg BENCH_BRANCH=v3.x --build-arg GIT_BENCH_URL=github.com/frappe/bench.git \
  -t dock.elasticrun.in/er-frappe10-base:${TAG} .
  #GIT_FRAPPE_URL=engg.elasticrun.in/tredrun/tredrun-core/frappe.git
  #GIT_BENCH_URL=engg.elasticrun.in/tredrun/tredrun-core/bench.git
