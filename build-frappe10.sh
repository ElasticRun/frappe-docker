#! /bin/bash
# Uses default frappe and bench master branches from github to build the docker image. Use own URLs to override.
docker build -f Dockerfile_frappe10 \
  --build-arg GIT_FRAPPE_URL=github.com/frappe/frappe.git --build-arg GIT_BENCH_URL=github.com/frappe/bench.git \
  -t dock.elasticrun.in/er-frappe10-base:dev .
  #GIT_FRAPPE_URL=engg.elasticrun.in/tredrun/tredrun-core/frappe.git
  #GIT_BENCH_URL=engg.elasticrun.in/tredrun/tredrun-core/bench.git
