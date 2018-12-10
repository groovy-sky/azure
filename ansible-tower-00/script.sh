#!/bin/bash

if [ -z $1 ] || [ -z $2 ]
then
 exit 1
fi

deployment_group=$1;
subscription_id=$2;

echo "Selecting subscription"
az account set -s $subscription_id

email=$(az account show -o tsv --query user.name)

echo "Initial deploy"
output_data=$(az group deployment create --resource-group $deployment_group --template-file azuredeploy.json --query "[properties.outputs]")

echo "Getting VM data"
vm_name=$(echo $output_data | jq --raw-output '.[0]."vm-name".value')
vm_fqdn=$(echo $output_data | jq --raw-output '.[0]."vm-fqdn".value')

echo "Installing NGINX"
az vm extension set --resource-group $deployment_group --vm-name $vm_name --name customScript --publisher Microsoft.Azure.Extensions --settings '{  "commandToExecute": "sudo apt-get update; sudo apt-get install nginx -y;"}'
az vm extension set --resource-group $deployment_group --vm-name $vm_name --name customScript --publisher Microsoft.Azure.Extensions --settings '{  "commandToExecute": "sudo mv /etc/nginx/sites-enabled/default /etc/nginx/sites-enabled/default_original;"}'


echo "Installing Certbot"
az vm extension set --resource-group $deployment_group --vm-name $vm_name --name customScript --publisher Microsoft.Azure.Extensions --settings '{  "commandToExecute": "sudo add-apt-repository ppa:certbot/certbot -y; sudo apt-get update; sudo apt-get install python-certbot-nginx -y;"}'

echo "Configuring NGINX for Certbot"
az vm extension set --resource-group $deployment_group --vm-name $vm_name --name customScript --publisher Microsoft.Azure.Extensions --settings '{  "commandToExecute": "sudo sed -i \"/http {/a server_names_hash_bucket_size 512;\" /etc/nginx/nginx.conf;sudo systemctl reload-or-restart nginx;"}'

echo "Initializing Certbot"
az vm extension set --resource-group $deployment_group --vm-name $vm_name --name customScript --publisher Microsoft.Azure.Extensions --settings '{  "commandToExecute": "sudo certbot --nginx -d '$vm_fqdn' -m '$email' --agree-tos -n;"}'

echo "Adding Docker repo"
az vm extension set --resource-group $deployment_group --vm-name $vm_name --name customScript --publisher Microsoft.Azure.Extensions --settings '{  "commandToExecute": "sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -; sudo apt-key fingerprint 0EBFCD88; sudo add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable\";"}'

echo "Installing and configuring docker swarm"
az vm extension set --resource-group $deployment_group --vm-name $vm_name --name customScript --publisher Microsoft.Azure.Extensions --settings '{  "commandToExecute": "sudo apt-get update; sudo apt-get install docker-ce -y; "}'

echo "Installing docker-py"
az vm extension set --resource-group $deployment_group --vm-name $vm_name --name customScript --publisher Microsoft.Azure.Extensions --settings '{  "commandToExecute": "sudo apt-get install python-pip -y; export LC_ALL=C; sudo pip install docker-py;"}'

echo "Data disk partitioning"
az vm extension set --resource-group $deployment_group --vm-name $vm_name --name customScript --publisher Microsoft.Azure.Extensions --settings '{  "commandToExecute": "sudo parted /dev/sdc mklabel msdos; sleep 30; sudo parted -a opt /dev/sdc mkpart primary ext4 0% 100%; sleep 30; sudo mkfs.ext4 -L datadisk /dev/sdc1; sleep 30;"}'
az vm extension set --resource-group $deployment_group --vm-name $vm_name --name customScript --publisher Microsoft.Azure.Extensions --settings '{  "commandToExecute": "sudo mkdir -p /media/data/; DATA_DISK_UUID=$(sudo blkid /dev/sdc1 -o value | grep \"[a-fA-F0-9]\{8\}-[a-fA-F0-9]\{4\}-[a-fA-F0-9]\{4\}-[a-fA-F0-9]\{4\}-[a-fA-F0-9]\{12\}\"); sudo echo \"UUID=$DATA_DISK_UUID /media/data/ auto defaults 0 2\" >> /etc/fstab;"}'

echo "Mount Data disk"
az vm extension set --resource-group $deployment_group --vm-name $vm_name --name customScript --publisher Microsoft.Azure.Extensions --settings '{  "commandToExecute": "sudo mount -a;"}'

echo "Installing Ansible"
az vm extension set --resource-group $deployment_group --vm-name $vm_name --name customScript --publisher Microsoft.Azure.Extensions --settings '{  "commandToExecute": "sudo apt-add-repository ppa:ansible/ansible -y; sudo apt-get update; sudo apt install ansible -y;"}'

echo "Initial clone Tower sources"
az vm extension set --resource-group $deployment_group --vm-name $vm_name --name customScript --publisher Microsoft.Azure.Extensions --settings '{  "commandToExecute": "sudo git clone https://github.com/ansible/awx.git /mnt/awx;"}'

echo "Setting up Tower configuration"
az vm extension set --resource-group $deployment_group --vm-name $vm_name --name customScript --publisher Microsoft.Azure.Extensions --settings '{  "commandToExecute": "sudo sed -i \"/postgres_data_dir/d\" /mnt/awx/installer/inventory;"}'
az vm extension set --resource-group $deployment_group --vm-name $vm_name --name customScript --publisher Microsoft.Azure.Extensions --settings '{  "commandToExecute": "sudo sed -i \"s/host_port=80/host_port=8080/g\" /mnt/awx/installer/inventory;"}'
az vm extension set --resource-group $deployment_group --vm-name $vm_name --name customScript --publisher Microsoft.Azure.Extensions --settings '{  "commandToExecute": "sudo sed -i \"/8080/apostgres_data_dir=\/media\/data\" /mnt/awx/installer/inventory;"}'
az vm extension set --resource-group $deployment_group --vm-name $vm_name --name customScript --publisher Microsoft.Azure.Extensions --settings '{  "commandToExecute": "sudo ansible-playbook -i /mnt/awx/installer/inventory /mnt/awx/installer/install.yml;"}'
