#!/bin/bash

# Virtual Network and subnet Creation
echo "Virtual Network and subnet Creation"
az network vnet create \
  --name $VNet \
  --resource-group $ResourceGroup \
  --address-prefix $AdresseStart$NetworkRange \
  --subnet-name $Subnet \
  --subnet-prefixes $AdresseStart$SubnetRange

# Create a network security group for Bastion
echo "Create a network security group for Bastion"
az network nsg create \
  --resource-group $ResourceGroup \
  --name $NsgBastionName 

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
  --destination-port-range $NsgBastionRuleSSHPort

# Create a network security group for Application
echo "Create a network security group for Application"
az network nsg create \
  --resource-group $ResourceGroup \
  --name $NsgAppliName

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
  --source-address-prefix "*" \
  --source-port-range "*" \
  --destination-port-range 22

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
  --priority 1010 \
  --source-address-prefix "*" \
  --source-port-range "*" \
  --destination-port-range 443

# Network Interface Card Creation
echo "Public IP VM Bastion Creation"
az network nic create \
    --resource-group $ResourceGroup \
    --name $Nic \
    --vnet-name $VNet \
    --subnet $Subnet

#Public IP VM Bastion Creation
echo "Public IP VM Bastion Creation"
az network public-ip create \
    --resource-group $ResourceGroup \
    --name $BastionIPName \
    --version IPv4 \
    --sku Standard \
    --zone $Zone

#Public IP VM Application Creation
echo "Public IP VM Application Creation"
az network public-ip create \
    --resource-group $ResourceGroup \
    --name $AppliIPName \
    --version IPv4 \
    --sku Standard \
    --zone $Zone

# Label Public IP VM Bastion Update
echo "Label Public IP VM Bastion Update"
az network public-ip update \
 --resource-group $ResourceGroup \
 --name $BastionIPName \
 --dns-name $LabelBastionIPName \
 --allocation-method Static

# Label Public IP VM Application Update
echo "Label Public IP VM Application Update"
az network public-ip update \
 --resource-group $ResourceGroup \
 --name $AppliIPName \
 --dns-name $LabelAppliIPName \
 --allocation-method Static

# Generate SSH Key
ssh-keygen -t rsa -b 4096 -N '' -C $SshKeyMail -f "/home/$USER/.ssh/"$SshKeyName"_rsa"

# SSH Config file Create/Add
if [ ! -e $HOME/.ssh/config ] || !(grep "$LabelBastionIPName" $HOME/.ssh/config) ; then
    echo -e "
Host "$LabelBastionIPName"
  Hostname "$LabelBastionIPName".westeurope.cloudapp.azure.com
  User "$BastionUserName"
  Port "$NsgBastionRuleSSHPort"
  IdentityFile "$HOME"/.ssh/"$SshKeyName"_rsa
  ForwardAgent yes
  " >> $HOME/.ssh/config
fi

# Data Disk VM Application Creation
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
  --user-data $BastionVMUserData \
  --vnet-name $VNet \
  --subnet $Subnet \
  --private-ip-address $BastionVMIPprivate \
  --nsg $NsgBastionName \
  --public-ip-address $BastionIPName \
  --admin-username $BastionUserName \
  --ssh-key-values "/home/$USER/.ssh/"$SshKeyName"_rsa.pub" \
  --zone $Zone 

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
  --user-data $AppliVMUserData \
  --vnet-name $VNet \
  --subnet $Subnet\
  --private-ip-address $AppliVMIPprivate \
  --nsg $NsgAppliName \
  --public-ip-address $AppliIPName \
  --admin-username $AppliUserName \
  --ssh-key-values "/home/$USER/.ssh/"$SshKeyName"_rsa.pub" \
  --zone $Zone

