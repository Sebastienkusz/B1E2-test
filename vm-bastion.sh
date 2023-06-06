#!/bin/bash

# VM Bastion Variables
BastionName=$PreName"VM-Bastion"
ImageOs="Ubuntu2204"	# 0001-com-ubuntu-server-focal:22_04-lts-gen2
BastionUserName="nextcloud"
BastionVMSize="Standard_B2s"

#VM Bastion Creation
az vm create \
  --resource-group $ResourceGroup \
  –attach-os-disk $OSDiskBastion \
  --name $BastionName \
  --size $BastionVMSize \
  --image $ImageOs \
  –nics $Nic \
  –subnet $Subnet\
  --public-ip-address $BastionIPName \
  --admin-username $BastionUserName \
  --custom-data script-vm-bastion.sh \
  –ssh-key-name $SshKey \
  --no-wait