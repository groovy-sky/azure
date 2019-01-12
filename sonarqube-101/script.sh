#!/bin/bash
if [ -z $1 ] || [ -z $2 ] || [ -z $3 ]
then
 exit 1
fi

subscription_id=$1;
deployment_group=$2;
sql_pass=$3;

echo "Selecting subscription"
az account set -s $subscription_id

echo "Initial deploy"
output_data=$(az group deployment create --resource-group $deployment_group --template-file azuredeploy.json --query "[properties.outputs]" --parameters postgresqlUsernamePassword=$sql_pass)

echo "Getting VM data"
vm_name=$(echo $output_data | jq --raw-output '.[0]."vm-name".value')
vm_fqdn=$(echo $output_data | jq --raw-output '.[0]."vm-fqdn".value')

email=$(az account show -o tsv --query user.name)

sql_server=$(echo $output_data | jq --raw-output '.[0]."sql-server".value')
sql_user=$(echo $output_data | jq --raw-output '.[0]."sql-user".value')

file_share=$(echo $output_data | jq --raw-output '.[0]."file-share".value')
storage=$(echo $output_data | jq --raw-output '.[0]."storage".value')


sql_jdbc="jdbc:postgresql://$sql_server.postgres.database.azure.com:5432/$sql_server?user=$sql_user@$sql_server&password=$sql_pass&sslmode=required"

echo "Installing NGINX"
az vm extension set --resource-group $deployment_group --vm-name $vm_name --name customScript --publisher Microsoft.Azure.Extensions --settings '{  "commandToExecute": "sudo apt-get update; sudo apt-get install nginx -y;"}'

echo "Installing Certbot"
az vm extension set --resource-group $deployment_group --vm-name $vm_name --name customScript --publisher Microsoft.Azure.Extensions --settings '{  "commandToExecute": "sudo add-apt-repository ppa:certbot/certbot -y; sudo apt-get update; sudo apt-get install python-certbot-nginx -y;"}'

echo "Configuring NGINX and initating Certbot"
az vm extension set --resource-group $deployment_group --vm-name $vm_name --name customScript --publisher Microsoft.Azure.Extensions --settings '{  "commandToExecute": "sudo sed -i \"/http {/a server_names_hash_bucket_size 512;\" /etc/nginx/nginx.conf;sudo systemctl reload-or-restart nginx;sudo certbot --nginx -d '$vm_fqdn' -m '$email' --agree-tos -n;"}'

echo "Adding Docker repo"
az vm extension set --resource-group $deployment_group --vm-name $vm_name --name customScript --publisher Microsoft.Azure.Extensions --settings '{  "commandToExecute": "sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -; sudo apt-key fingerprint 0EBFCD88; sudo add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable\";"}'

echo "Configuring and installing docker"
az vm extension set --resource-group $deployment_group --vm-name $vm_name --name customScript --publisher Microsoft.Azure.Extensions --settings '{  "commandToExecute": "sudo apt-get update; sudo apt-get install docker-ce -y;sudo apt-get install python-pip -y; export LC_ALL=C; sudo pip install docker-py;"}'

echo "Installing docker compose"
#az vm extension set --resource-group $deployment_group --vm-name $vm_name --name customScript --publisher Microsoft.Azure.Extensions --settings '{  "commandToExecute": "sudo pip install docker-compose;"}'
#az vm extension set --resource-group $deployment_group --vm-name $vm_name --name customScript --publisher Microsoft.Azure.Extensions --settings '{  "commandToExecute": "sudo apt-get install -y docker-compose;"}'



echo "Installing docker compose"
#az vm extension set --resource-group $deployment_group --vm-name $vm_name --name customScript --publisher Microsoft.Azure.Extensions --settings '{  "commandToExecute": "sudo echo \"version: double_quotes2double_quotes \" > /opt/docker-compose.yml; sudo echo \"services:\" >> /opt/docker-compose.yml; sudo echo \"  sonarqube:\" >> /opt/docker-compose.yml; sudo echo \"    image: sonarqube:lts\" >> /opt/docker-compose.yml; sudo echo \"    ports:\" >> /opt/docker-compose.yml; sudo echo \"      - double_quotes9000:9000double_quotes \" >> /opt/docker-compose.yml; sudo echo \"    environment:\" >> /opt/docker-compose.yml; sudo echo \"      - sonar.jdbc='$sql_jdbc' \" >> /opt/docker-compose.yml;"}'

az vm extension set --resource-group $deployment_group --vm-name $vm_name --name customScript --publisher Microsoft.Azure.Extensions --settings '{  "commandToExecute": "sudo wget https://raw.githubusercontent.com/groovy-sky/azure/master/sonarqube-101/docker-compose.yml -P /opt/;"}'

az vm extension set --resource-group $deployment_group --vm-name $vm_name --name customScript --publisher Microsoft.Azure.Extensions --settings "{  \"commandToExecute\": \"sudo sed -i 's|sql_jdbc|"$sql_jdbc"|g' /opt/docker-compose.yml; \"}"


#az vm extension set --resource-group $deployment_group --vm-name $vm_name --name customScript --publisher Microsoft.Azure.Extensions --settings '{  "commandToExecute": "sudo docker-compose -f /opt/docker-compose.yml up -d;"}'

az vm extension set --resource-group $deployment_group --vm-name $vm_name --name customScript --publisher Microsoft.Azure.Extensions --settings '{  "commandToExecute": "sudo touch sim4805td;"}'


echo "NGINX configuring as reverse proxy"
az vm extension set --resource-group $deployment_group --vm-name $vm_name --name customScript --publisher Microsoft.Azure.Extensions --settings '{  "commandToExecute": "sudo sed -i \"0,/listen 80/{s/listen 80/#listen 80/}\" /etc/nginx/sites-enabled/default;sudo sed -i \"/\slisten 80/d\" /etc/nginx/sites-enabled/default; sudo sed -i \"0,/#listen 80/{s/#listen 80/listen 80/}\" /etc/nginx/sites-enabled/default;"}'
az vm extension set --resource-group $deployment_group --vm-name $vm_name --name customScript --publisher Microsoft.Azure.Extensions --settings '{  "commandToExecute": "sudo sed -i \"0,/listen\s\[::\]/{s/listen\s\[::\]/#listen [::]/}\" /etc/nginx/sites-enabled/default; sudo sed -i \"/\slisten\s\[::\]/d\" /etc/nginx/sites-enabled/default; sudo sed -i \"0,/#listen\s\[::\]/{s/#listen\s\[::\]/listen [::]/}\" /etc/nginx/sites-enabled/default;"}'
az vm extension set --resource-group $deployment_group --vm-name $vm_name --name customScript --publisher Microsoft.Azure.Extensions --settings '{  "commandToExecute": "sudo sed -i \"0,/root/{s/root/#root/}\" /etc/nginx/sites-enabled/default; sudo sed -i \"/^[[:space:]]root/d\" /etc/nginx/sites-enabled/default;"}'
az vm extension set --resource-group $deployment_group --vm-name $vm_name --name customScript --publisher Microsoft.Azure.Extensions --settings '{  "commandToExecute": "sudo sed -i \"0,/location/{s/location/#location/}\" /etc/nginx/sites-enabled/default;"}'
az vm extension set --resource-group $deployment_group --vm-name $vm_name --name customScript --publisher Microsoft.Azure.Extensions --settings '{  "commandToExecute": "sudo sed -i \"/^[[:space:]]location/aproxy_set_header Host \$host;\\nproxy_pass http\:\/\/127.0.0.1:9000; \" /etc/nginx/sites-enabled/default;"}'
az vm extension set --resource-group $deployment_group --vm-name $vm_name --name customScript --publisher Microsoft.Azure.Extensions --settings '{  "commandToExecute": "sudo sed -i \"0,/#location/{s/#location/location/}\" /etc/nginx/sites-enabled/default;"}'
az vm extension set --resource-group $deployment_group --vm-name $vm_name --name customScript --publisher Microsoft.Azure.Extensions --settings '{  "commandToExecute": "sudo sed -i \"0,/try_files/{s/try_files/#try_files/}\" /etc/nginx/sites-enabled/default; sudo sed -i \"/[[:space:]]try_files/d\" /etc/nginx/sites-enabled/default;"}'

echo "Reload NGINX config"
az vm extension set --resource-group $deployment_group --vm-name $vm_name --name customScript --publisher Microsoft.Azure.Extensions --settings '{  "commandToExecute": "sudo systemctl reload-or-restart nginx;"}'

