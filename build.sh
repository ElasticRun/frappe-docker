#! /bin/bash
if [ $# -gt 0 ]
then
  TAG=$1
else
  TAG=ubuntu
fi
#Frappe branch to use. Can also be a name of the tag
FRAPPE_BRANCH=v11.1.59
# Uses default frappe and bench master branches from github to build the docker image. Use own URLs to override.
# --build-arg GIT_BENCH_URL=github.com/frappe/bench.git \
# --build-arg GIT_FRAPPE_URL=github.com/frappe/frappe.git \
docker build --build-arg CUR_DATE=$(date +%Y-%m-%d:%H:%M:%S) --build-arg KAFKA_CONFIG='${KAFKA_CONFIG}' \
  --build-arg GIT_FRAPPE_URL=github.com/frappe/frappe.git \
  --build-arg FRAPPE_BRANCH=${FRAPPE_BRANCH} \
  --build-arg GIT_BENCH_URL=github.com/frappe/bench.git \
  --build-arg BENCH_BRANCH=master \
  -t frappe11-base:${TAG}-xenial .

