---
Azure Unmanaged Data Disk Encryption for IaaS VMs
---

This article details how to encrypt unmanaged data virtual disks on a Linux VM using the Azure CLI 2.0. 

Virtual disks on Linux VMs are encrypted at rest using dm-crypt. Cryptographic keys are stored in Azure Key Vault. These cryptographic keys are used to encrypt and decrypt virtual disks attached to your VM. 

Azure disk encryption has [some limitations](https://docs.microsoft.com/en-us/azure/security/azure-security-disk-encryption-faq), which is important to bear in mind. 

Encryption scenarios:
1. Long-running encryption
2. Fast-running encryption 

```
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
spn=($(az ad sp create-for-rbac -n $app_name --query [appId,password] -o tsv))
az keyvault set-policy --name $vault_name --spn ${spn[0]} --key-permissions wrapKey --secret-permissions set


az vm extension set --resource-group $deploy_group --vm-name $vm_name --name customScript --publisher Microsoft.Azure.Extensions --settings '{  "commandToExecute": "sudo parted /dev/sdc mklabel msdos; sleep 30; sudo parted -a opt /dev/sdc mkpart primary ext4 0% 100%; sleep 30; sudo mkfs.ext4 -L '$disk_label' /dev/sdc1; sleep 30;"}'

az vm extension set --resource-group $deploy_group --vm-name $vm_name --name customScript --publisher Microsoft.Azure.Extensions --settings '{  "commandToExecute": "sudo mkdir -p '$mount_point'; DATA_DISK_UUID=$(sudo blkid $(sudo blkid -L '$disk_label') -o value | grep \"[a-fA-F0-9]\{8\}-[a-fA-F0-9]\{4\}-[a-fA-F0-9]\{4\}-[a-fA-F0-9]\{4\}-[a-fA-F0-9]\{12\}\"); sudo echo \"UUID=$DATA_DISK_UUID '$mount_point' auto defaults,nofail 0 2\" >> /etc/fstab;"}'

az vm encryption enable --disk-encryption-keyvault $vault_name --name $vm_name --resource-group $deploy_group --aad-client-id ${spn[0]} --aad-client-secret ${spn[1]} --volume-type DATA

while [[ "$(az vm encryption show --name $vm_name --resource-group $deploy_group --query "dataDisk" -o tsv)" == "EncryptionInProgress" ]]
do
 echo "Disk is not encrypted yet. Next check after one minute."
 sleep 60
done

az vm restart -g $deploy_group -n $vm_name
```

![Before encryption](/images/linux-vm-encryption-101/before_encryption_00.png)
![After encryption](/images/linux-vm-encryption-101/after_encryption_00.png)


https://docs.microsoft.com/en-us/azure/virtual-machines/linux/encrypt-disks

https://docs.microsoft.com/en-us/azure/security/azure-security-disk-encryption
