---
Azure Unmanaged Data Disk Encryption for IaaS VMs
---

# Overview

This article details how to encrypt unmanaged data virtual disks on a Linux VM using the Azure CLI 2.0. 

Virtual disks on Linux VMs are encrypted at rest using dm-crypt. Cryptographic keys are stored in Azure Key Vault. These cryptographic keys are used to encrypt and decrypt virtual disks attached to your VM. 

Azure disk encryption has [some limitations](https://docs.microsoft.com/en-us/azure/security/azure-security-disk-encryption-faq), which is important to bear in mind. In this article used configuration is following:
Linux VM with Ubuntu 16.04 LTS / Standard DS1 v2 / Data disk is unmanaged and has 10 Gb capacity

Encryption scenarios:
1. Long-running encryption (without formatting)
2. Fast-running encryption (with formatting)

# Long-running disk encryption

```
deploy_group="group"$(date +%s)
vm_name="vmname"$(date +%s)
vault_name="keyvaultname"$(date +%s)
disk_label="encryptiondisk"
mount_point="/media"
app_name=$vault_name"-spn"

az group create --name $deploy_group -l westeurope
az vm create -g $deploy_group -n $vm_name --image ubuntults --storage-sku Standard_LRS --use-unmanaged-disk
az vm unmanaged-disk attach -g $deploy_group --vm-name $vm_name --size-gb 10 --new

az keyvault create --name $vault_name --resource-group $deploy_group --enabled-for-disk-encryption

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
Important aspect of such encryption is data device name - during encryption, the order of drives changes on the VM. For example on the next two images you can see that a device with UUID="fcdfd67c-2172-4c81-8829-28052d1caebf" and LABEL="encryptiondisk" has changed it name from /dev/sdc1 to /dev/mapper/75a2b91d-b3b1-4f87-adcf-985c3fc6528c. Which is why it is important to use UUID to specify data drives in /etc/fstab instead of specifying the block device name.
Before encrytion:
![Before encryption](/images/linux-vm-encryption-101/before_encryption_00.png)
After encrytion:
![After encryption](/images/linux-vm-encryption-101/after_encryption_00.png)
Another important note about encryption proccess itself - it is recommended before encryption initialization make [a disk backup](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/incremental-snapshots) and during encryption proccess do not connect to a virtual machine.

https://docs.microsoft.com/en-us/azure/virtual-machines/linux/encrypt-disks

https://docs.microsoft.com/en-us/azure/security/azure-security-disk-encryption
