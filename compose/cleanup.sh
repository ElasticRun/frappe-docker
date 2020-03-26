#! /bin/bash
echo "Stopping compose environment (if it is running)"
docker-compose down
rm -f ./sites/site1.docker/.lock
rm -f ./sites/site1.docker/site_config.json
sudo rm -rf ./mariadb_data/*
rm -rf logs/*