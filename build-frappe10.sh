#! /bin/bash
TAG=$1
# Uses default frappe and bench master branches from github to build the docker image. Use own URLs to override.
echo "Kafka Config : '${KAFKA_CONFIG}'"
docker build -f Dockerfile_frappe10 --build-arg KAFKA_CONFIG='${KAFKA_CONFIG}' \
  --build-arg BENCH_BRANCH=master --build-arg GIT_AUTH_USER=gitlab-runner \
  --build-arg GIT_AUTH_PASSWORD=t3ms-GEWD7EhD_moXVUr \
  -t dock.elasticrun.in/er-frappe10-base:${TAG} .
  #GIT_FRAPPE_URL=engg.elasticrun.in/tredrun/tredrun-core/frappe.git
  #GIT_BENCH_URL=engg.elasticrun.in/tredrun/tredrun-core/bench.git
