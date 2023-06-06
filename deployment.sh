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

#NSG VM Bastion Variables
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
  --name Allow-SSH-All \
  --access Allow \
  --protocol Tcp \
  --direction Inbound \
  --priority 110 \
  --source-address-prefix Internet \
  --source-port-range "*" \
  --destination-port-range 22

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

#OS Disk VM Bastion Variables
OSDiskBastion=$PreName"VM-Bastion-OS-Disk"
# S4 for 32 Go HDD Standard
OSDiskBastionSize="S4"
OSDiskBastionSizeGB="30"

#OS Disk VM Bastion Creation
echo "OS Disk VM Bastion Creation"
az disk create \
  --resource-group $ResourceGroup \
  --name $OSDiskBastion \
  --architecture x64 \
  --os-type linux \
  --size-gb $OSDiskBastionSizeGB \
  --tier $OSDiskBastionSize \
  --zone $Zone

#OS Disk VM Application Variables
OSDiskAppli=$PreName"VM-Appli-OS-Disk"
# E4 for 32 Go SSD Standard
OSDiskAppliSize="E4"
OSDiskAppliSizeGB="30"

#OS Disk VM Application Creation
echo "OS Disk VM Application Creation"
az disk create \
  --resource-group $ResourceGroup \
  --name $OSDiskAppli \
  --architecture x64 \
  --os-type linux \
  --size-gb $OSDiskAppliSizeGB \
  --tier $OSDiskAppliSize \
  --zone $Zone

#Data Disk VM Application Variables
DataDiskAppli=$PreName"VM-Appli-Data-Disk"
# E6 for 64 Go SSD Standard
DataDiskAppliSize="E6"

#Data Disk VM Application Creation
echo "Data Disk VM Application Creation"
az disk create \
  -–resource-group $ResourceGroup \
  -–name $DataDiskAppli \
  -–architecture x64 \
  -–os-type linux \
  -–tier $DataDiskAppliSize \
  -–zone $Zone

  # Key Vault Variables
KeyVaultName=$PreName"KeyVault"

# Key Vault Creation
echo "Key Vault Creation"
az keyvault create \
  --resource-group $ResourceGroup \
  --location $Location \
  --name $KeyVaultName \
  --enabled-for-disk-encryption
#–secure-vm-disk-encryption-set

# SSH key Variables
SshKey=$PreName"VM-SSH-key"

# SSH Key Creation
echo "SSH Key Creation"
az sshkey create \
  -–resource-group $ResourceGroup \
  -–location $Location \
  -–public-key “{ssh-rsa public key}” \
  -–name $SshKey

# VM Bastion Variables
BastionName=$PreName"VM-Bastion"
ImageOs="Ubuntu2204"	# 0001-com-ubuntu-server-focal:22_04-lts-gen2
BastionUserName="nextcloud"
BastionVMSize="Standard_B2s"

#VM Bastion Creation
echo "VM Bastion Creation"
az vm create \
  --resource-group $ResourceGroup \
  --attach-os-disk $OSDiskBastion \
  --name $BastionName \
  --size $BastionVMSize \
  --image $ImageOs \
  --nics $Nic \
  --subnet $Subnet\
  --public-ip-address $BastionIPName \
  --admin-username $BastionUserName \
  -–ssh-key-name $SshKey \
  --no-wait