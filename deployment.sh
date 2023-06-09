#!/bin/bash

# Variables
# Resource Group
ResourceGroup="Sebastien_K"
Location="westeurope"
Zone="3"
PreName="W-B1E2-"

# Virtual Network
VNet=$PreName"Network"
AdresseStart="10.0.0.0"
NetworkRange="/16"

# Subnet
Subnet=$PreName"Subnet-Nextcloud"
SubnetRange="/29"

# Virtual Network and subnet Creation
echo "Virtual Network and subnet Creation"
az network vnet create \
  --name $VNet \
  --resource-group $ResourceGroup \
  --address-prefix $AdresseStart$NetworkRange \
  --subnet-name $Subnet \
  --subnet-prefixes $AdresseStart$SubnetRange

# NSG VM Bastion Variables
NsgBastionName=$PreName"NSG-Bastion"

# Create a network security group for Bastion
echo "Create a network security group for Bastion"
az network nsg create \
  --resource-group $ResourceGroup \
  --name $NsgBastionName

#NSG Rules VM Bastion Variables
NsgBastionRules=$PreName"NSG-Rules-Bastion"

# Create Rules in network security group for Bastion
echo "Create Rules in network security group for Bastion"
az network nsg rule create \
  --resource-group $ResourceGroup \
  --nsg-name $NsgBastionName \
  --name Allow-SSH-All \
  --access Allow \
  --protocol Tcp \
  --direction Inbound \
  --priority 110 \
  --source-port-range "*" \
  --destination-port-range 10022

#NSG VM Application Variables
NsgAppliName=$PreName"NSG-Appli"

# Create a network security group for Application
echo "Create a network security group for Application"
az network nsg create \
  --resource-group $ResourceGroup \
  --name $NsgAppliName

#NSG Rules VM Appli Variables
NsgAppliRules=$PreName"NSG-Rules-Appli"

# Create Rules in network security group for Application
echo "Create Rules in network security group for Application"
az network nsg rule create \
  --resource-group $ResourceGroup \
  --nsg-name $NsgAppliName \
  --name Allow-HTTP-All \
  --access Allow \
  --protocol Tcp \
  --direction Inbound \
  --priority 1000 \
  --source-address-prefix "*" \
  --source-port-range "*" \
  --destination-port-range 80

az network nsg rule create \
  --resource-group $ResourceGroup \
  --nsg-name $NsgAppliName \
  --name Allow-HTTPS-All \
  --access Allow \
  --protocol Tcp \
  --direction Inbound \
  --priority 1000 \
  --source-address-prefix "*" \
  --source-port-range "*" \
  --destination-port-range 443

#Public IP VM Bastion Variables
Nic=$PreName"Nic"

#Public IP VM Bastion Creation
echo "Public IP VM Bastion Creation"
az network nic create \
    --resource-group $ResourceGroup \
    --name $Nic \
    --vnet-name $VNet \
    --subnet $Subnet

#Public IP VM Bastion Variables
BastionIPName=$PreName"VM-Bastion-IP"

#Public IP VM Bastion Creation
echo "Public IP VM Bastion Creation"
az network public-ip create \
    --resource-group $ResourceGroup \
    --name $BastionIPName \
    --version IPv4 \
    --sku Standard \
    --zone $Zone

#Public IP VM Application Variables
AppliIPName=$PreName"VM-Appli-IP"

#Public IP VM Application Creation
echo "Public IP VM Application Creation"
az network public-ip create \
    --resource-group $ResourceGroup \
    --name $AppliIPName \
    --version IPv4 \
    --sku Standard \
    --zone $Zone

# Label Public IP VM Bastion Variables
LabelBastionIPName="esan-preproduction-bastion"

# Label Public IP VM Bastion Update
echo "Label Public IP VM Bastion Update"
az network public-ip update \
 --resource-group $ResourceGroup \
 --name $BastionIPName \
 --dns-name $LabelBastionIPName \
 --allocation-method Static

 # Label Public IP VM Application Variables
LabelAppliIPName="esan-preproduction-nextcloud"

# Label Public IP VM Application Update
echo "Label Public IP VM Application Update"
az network public-ip update \
 --resource-group $ResourceGroup \
 --name $AppliIPName \
 --dns-name $LabelAppliIPName \
 --allocation-method Static

# # Key Vault Variables
# KeyVaultName=$PreName"KeyVault"

# # Key Vault Creation
# echo "Key Vault Creation"
# az keyvault create \
#   --resource-group $ResourceGroup \
#   --location $Location \
#   --name $KeyVaultName \
#   --enabled-for-disk-encryption
# #–secure-vm-disk-encryption-set

# # # SSH key Variables
# KeyName=$PreName"VM-SSH-keytest"
# SshKeyName=$PreName"rsa"
# SshPublicKeyPath="/home/"$USER"/.ssh/"
# SshKeyMail="kusz.sebastien@gmail.com"

# SSH Key Creation
# echo "SSH Key Creation"
# az sshkey create \
#   --resource-group $ResourceGroup \
#   --name $KeyName \
#   --location $Location \
#   --tag key[tototiti]

# ssh-keygen -t rsa -b 4096 -N '' -C "$SshKeyMail" -f "$SshPublicKeyPath$SshKeyName"

# Get public key content
# SshPublicKeyContent=$(cat "$SshPublicKeyPath$SshKeyName.pub")
# echo $SshPublicKeyContent

# Creation key in key vault
# az keyvault key create \
#   --name $KeyName \
#   --vault-name $KeyVaultName \
#   --kty RSA \
#   --ops encrypt decrypt sign verify wrapKey unwrapKey \
#   --protection software \
#   --size 4096 \
#   --disabled false

# # Import key in key vault
# az keyvault key import \
#   --vault-name $KeyVaultName \
#   --disabled false \
#   --protection software \
#   --kty RSA \
#   --name $KeyName \
#   --byok-file $SshPublicKeyPath$SshKeyName \
#   --ops encrypt decrypt sign verify wrapKey unwrapKey

# RSA SSH Variables

# RSA SSH Creation
SshKeyName=$PreName"Nextcloud"
read -p "Adresse e-mail : " SshKeyMail

ssh-keygen -t rsa -b 4096 -N '' -C $SshKeyMail -f "/home/$USER/.ssh/"$SshKeyName"_rsa"

# # Add ssh ket to ssh agent
# eval "$(ssh-agent -s)"
# ssh-add "/home/$USER/.ssh/"$SshKeyName"_rsa"

# Change ssh keys permissions
# sudo chmod 600 /home/$USER/.ssh/"$SshLocateKeyName"_rsa
# sudo chmod 644 /home/$USER/.ssh/"$SshLocateKeyName"_rsa.pub

# SSH Config file Create/Add
BastionUserName="nextcloud"
echo -e "\nHost "$LabelBastionIPName".westeurope.cloudapp.azure.com\n  IdentityFile ~/.ssh/"$SshKeyName"_rsa \n  ForwardAgent yes" >> /home/$USER/.ssh/config

#OS Disk VM Bastion Variables
OSDiskBastion=$PreName"VM-Bastion-OS-Disk"
# P4 for 32 Go SSD Preminum
OSDiskBastionSizeGB="30"
#OSDiskBastionSku="Standard_LRS"

# #OS Disk VM Bastion Creation
# echo "OS Disk VM Bastion Creation"
# az disk create \
#   --resource-group $ResourceGroup \
#   --name $OSDiskBastion \
#   --architecture "x64" \
#   --os-type "linux" \
#   --encryption-type "EncryptionAtRestWithPlatformKey" \
#   --image-reference "Canonical:0001-com-ubuntu-server-jammy:22_04-lts-gen2:latest" \
#   --size-gb $OSDiskBastionSizeGB \
#   --sku $OSDiskBastionSku \
#   --disk-iops-read-write 500 \
#   --disk-mbps-read-write 60 \
#   --location $Location \
#   --zone $Zone

#OS Disk VM Application Variables
OSDiskAppli=$PreName"VM-Appli-OS-Disk"
# P4 for 32 Go SSD Preminum
OSDiskAppliSizeGB="30"
# OSDiskAppliSku="StandardSSD_LRS"

#OS Disk VM Application Creation
# echo "OS Disk VM Application Creation"
# az disk create \
#   --resource-group $ResourceGroup \
#   --name $OSDiskAppli \
#   --architecture "x64" \
#   --os-type "linux" \
#   --encryption-type "EncryptionAtRestWithPlatformKey" \
#   --image-reference "Canonical:0001-com-ubuntu-server-jammy:22_04-lts-gen2:latest" \
#   --size-gb $OSDiskAppliSizeGB \
#   --sku $OSDiskAppliSku \
#   --disk-iops-read-write 500 \
#   --disk-mbps-read-write 60 \
#   --location $Location \
#   --zone $Zone

#Data Disk VM Application Variables
DataDiskAppli=$PreName"VM-Appli-Data-Disk"
# E6 for 64 Go SSD Standard
DataDiskAppliSizeGB="64"
DataDiskAppliSku="StandardSSD_LRS"

#Data Disk VM Application Creation
echo "Data Disk VM Application Creation"
az disk create \
  --resource-group $ResourceGroup \
  --name $DataDiskAppli \
  --architecture "x64" \
  --encryption-type "EncryptionAtRestWithPlatformKey" \
  --size-gb $DataDiskAppliSizeGB \
  --sku $DataDiskAppliSku \
  --disk-iops-read-write 500 \
  --disk-mbps-read-write 60 \
  --zone $Zone

# VM Bastion Variables
BastionName=$PreName"VM-Bastion"
ImageOs="Ubuntu2204"	# 0001-com-ubuntu-server-focal:22_04-lts-gen2
BastionVMSize="Standard_B2s"


#VM Bastion Creation
echo "VM Bastion Creation"
az vm create \
  --resource-group $ResourceGroup \
  --name $BastionName \
  --location $Location \
  --size $BastionVMSize \
  --image $ImageOs \
  --os-disk-name $OSDiskBastion \
  --os-disk-delete-option "Detach" \
  --os-disk-size-gb $OSDiskBastionSizeGB \
  --user-data "scriptvmbastion.sh" \
  --vnet-name $VNet \
  --subnet $Subnet \
  --private-ip-address 10.0.0.6 \
  --nsg $NsgBastionName \
  --public-ip-address $BastionIPName \
  --admin-username $BastionUserName \
  --ssh-key-values "/home/$USER/.ssh/"$SshKeyName"_rsa.pub" \
  --zone $Zone 


# VM Application Variables
AppliName=$PreName"VM-Appli"
AppliUserName="appli"
AppliVMSize="Standard_D2s_v3"

#VM Application Creation
az vm create \
  --resource-group $ResourceGroup \
  --attach-data-disks $DataDiskAppli \
  --name $AppliName \
  --location $Location \
  --size $AppliVMSize \
  --image $ImageOs \
  --os-disk-name $OSDiskAppli \
  --os-disk-delete-option "Detach" \
  --os-disk-size-gb $OSDiskAppliSizeGB \
  --vnet-name $VNet \
  --subnet $Subnet\
  --private-ip-address 10.0.0.5 \
  --nsg $NsgAppliName \
  --public-ip-address $AppliIPName \
  --admin-username $AppliUserName \
  --ssh-key-values "/home/$USER/.ssh/"$SshKeyName"_rsa.pub" \
  --user-data scriptvmappli.sh \
  --zone $Zone