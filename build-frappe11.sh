#! /bin/bash
TAG=$1
# Uses default frappe and bench master branches from github to build the docker image. Use own URLs to override.
docker build \
  --build-arg GIT_FRAPPE_URL=github.com/frappe/frappe.git --build-arg GIT_BENCH_URL=github.com/frappe/bench.git \
  -t dock.elasticrun.in/er-frappe11-base:${TAG} .
  #GIT_FRAPPE_URL=engg.elasticrun.in/tredrun/tredrun-core/frappe.git
  #GIT_BENCH_URL=engg.elasticrun.in/tredrun/tredrun-core/bench.git
