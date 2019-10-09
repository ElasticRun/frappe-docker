# For Azure
# current_env_conn_string=$(az storage account show-connection-string -n erbk8sappall -g er-bk8s-app-all-rsg --query 'connectionString' -o tsv)

# if [[ $current_env_conn_string == "" ]]; then
#     echo "Couldn't retrieve the connection string."
# fi
# az storage share create --name er-bk8s-test-site-share --quota 10240 --connection-string $current_env_conn_string > /dev/null

# For GCP
# gcloud compute disks list er-bk8s-test-site-pd --zones=asia-south1-b 2>&1
# if [ $? -ne 0 ]
# then
#     # This means the disk was not found (or some other error!)
#     echo "Creating new disk"
#     gcloud compute disks create er-bk8s-test-site-pd --size=10GB --zone=asia-south1-b
# fi
helm repo add --username repouser --password Ntex@123 er-develop https://helm.elasticrun.in/helm/develop
helm repo update
helm upgrade frappe11-test --install -f ./values-test.yaml --set persistence.pdName=er-bk8s-test-site-pd er-develop/er-frappe
