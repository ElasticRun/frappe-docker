if [ ! -d ./mariadb_data/data ]
then
    mkdir mariadb_data/data
    chmod 777 mariadb_data/data
fi
docker-compose up -d
echo "Frappe instance started. It can be accessed at http://localhost:8888"
echo "Press enter to view logs from frappe container..."
read
docker logs -f frappe11
