docker build --build-arg GIT_AUTH_USER=gitlab+deploy-token-27 --build-arg GIT_AUTH_PASSWORD=L5m1Srswu_mu3GigqJpp \
--build-arg GIT_FRAPPE_URL=engg.elasticrun.in/with-run/withrun-erp/frappe.git \
--build-arg GIT_BENCH_URL=github.com/frappe/bench.git -t dock.elasticrun.in/wr-frappe11-base:dev .