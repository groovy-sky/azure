deploy_group="group"$(date +%s)
vm_name="vmname"$(date +%s)
vault_name="keyvaultname"$(date +%s)
disk_label="encryptiondisk"
mount_point="/media"

az group create --name $deploy_group -l westeurope
az vm create -g $deploy_group -n $vm_name --image ubuntults --storage-sku Standard_LRS --use-unmanaged-disk
az vm unmanaged-disk attach -g $deploy_group --vm-name $vm_name --size-gb 10 --new

az keyvault create --name $vault_name --resource-group $deploy_group --enabled-for-disk-encryption


app_name=$vault_name"-spn"
#read app_id app_key <<< $(az ad sp create-for-rbac -n $app_name --query [appId,password] -o tsv)
spn=($(az ad sp create-for-rbac -n $app_name --query [appId,password] -o tsv))
az keyvault set-policy --name $vault_name --spn ${spn[0]} --key-permissions wrapKey --secret-permissions set


az vm extension set --resource-group $deploy_group --vm-name $vm_name --name customScript --publisher Microsoft.Azure.Extensions --settings '{  "commandToExecute": "sudo parted /dev/sdc mklabel msdos; sleep 30; sudo parted -a opt /dev/sdc mkpart primary ext4 0% 100%; sleep 30; sudo mkfs.ext4 -L '$disk_label' /dev/sdc1; sleep 30;"}'

az vm extension set --resource-group $deploy_group --vm-name $vm_name --name customScript --publisher Microsoft.Azure.Extensions --settings '{  "commandToExecute": "sudo mkdir -p '$mount_point'; DATA_DISK_UUID=$(sudo blkid $(sudo blkid -L '$disk_label') -o value | grep \"[a-fA-F0-9]\{8\}-[a-fA-F0-9]\{4\}-[a-fA-F0-9]\{4\}-[a-fA-F0-9]\{4\}-[a-fA-F0-9]\{12\}\"); sudo echo \"UUID=$DATA_DISK_UUID '$mount_point' auto defaults,nofail 0 2\" >> /etc/fstab;"}'

az vm encryption enable --disk-encryption-keyvault $vault_name --name $vm_name --resource-group $deploy_group --aad-client-id ${spn[0]} --aad-client-secret ${spn[1]} --volume-type DATA
