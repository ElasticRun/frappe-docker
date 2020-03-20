#! /bin/bash
TAG=$1
#FRAPPE_BRANCH=version-11
FRAPPE_BRANCH=v11.1.59
# Uses default frappe and bench master branches from github to build the docker image. Use own URLs to override.
echo "Kafka Config : '${KAFKA_CONFIG}'"

# --build-arg GIT_BENCH_URL=github.com/frappe/bench.git \
# --build-arg GIT_FRAPPE_URL=github.com/frappe/frappe.git \
docker build --build-arg CUR_DATE=$(date +%Y-%m-%d:%H:%M:%S) --build-arg KAFKA_CONFIG='${KAFKA_CONFIG}' \
  --build-arg GIT_FRAPPE_URL=engg.elasticrun.in/platform-foundation/frappe-core/frappe.git \
  --build-arg FRAPPE_BRANCH=${FRAPPE_BRANCH} \
  --build-arg FRAPPE_AUTH_USER=gitlab-runner \
  --build-arg FRAPPE_AUTH_PASSWORD=ouZtSxs4bPcs_TbQnz3i \
  --build-arg GIT_BENCH_URL=engg.elasticrun.in/platform-foundation/frappe-core/bench.git \
  --build-arg BENCH_AUTH_USER=er-frappe-docker-base \
  --build-arg BENCH_AUTH_PASSWORD=f3JxMW8xr3MFCMxwydfS \
  --build-arg BENCH_BRANCH=master \
  -t dock.elasticrun.in/er-frappe11-base:${TAG}-xenial -f Dockerfile_ubuntu .
if [ "X${CI_COMMIT_SHORT_SHA}" != "X" ]
then
  docker tag dock.elasticrun.in/er-frappe11-base:${TAG}-xenial dock.elasticrun.in/er-frappe11-base:${CI_COMMIT_SHORT_SHA}-xenial
  echo "Tagged version image as dock.elasticrun.in/er-frappe11-base:${CI_COMMIT_SHORT_SHA}-xenial"
fi
