#!/bin/bash

# Variables
# Resource Group
export ResourceGroup="Sebastien_K"
export Location="westeurope"
export Zone="3"
export PreName="W-B1E2-"

# Virtual Network
export VNet=$PreName"Network"
export AdresseStart="10.0.0.0"
export NetworkRange="/16"

# Subnet
export Subnet=$PreName"Subnet-Nextcloud"
export SubnetRange="/28"

# NSG VM Bastion Variables
export NsgBastionName=$PreName"NSG-Bastion"

#NSG Rules VM Bastion Variables
export NsgBastionRules=$PreName"NSG-Rules-Bastion"
export NsgBastionRuleSSHPort="10022"

#NSG VM Application Variables
export NsgAppliName=$PreName"NSG-Appli"


#NSG Rules VM Appli Variables
export NsgAppliRules=$PreName"NSG-Rules-Appli"

# Network Interface Card Variables
export Nic=$PreName"Nic"

#Public IP VM Bastion Variables
export BastionIPName=$PreName"VM-Bastion-IP"

#Public IP VM Application Variables
export AppliIPName=$PreName"VM-Appli-IP"

# Label Public IP VM Bastion Variables - Record DNS
export LabelBastionIPName="esan-preproduction-bastion"

# Label Public IP VM Application Variables - Record DNS
export LabelAppliIPName="esan-preproduction-nextcloud"

# RSA SSH Creation
export SshKeyName=$PreName"Nextcloud"

# OS Disk VM Bastion
export OSDiskBastion=$PreName"VM-Bastion-OS-Disk"
export OSDiskBastionSizeGB="30"

# OS Disk VM Application
export OSDiskAppli=$PreName"VM-Appli-OS-Disk"
export OSDiskAppliSizeGB="30"

#Data Disk VM Application Variables
export DataDiskAppli=$PreName"VM-Appli-Data-Disk"
export DataDiskAppliSizeGB="64"
export DataDiskAppliSku="StandardSSD_LRS"

# VM Bastion Variables
export BastionName=$PreName"VM-Bastion"
export ImageOs="Ubuntu2204"	# 0001-com-ubuntu-server-focal:22_04-lts-gen2
export BastionVMSize="Standard_B2s"
export BastionVMUserData="script-vm-bastion.sh"
export BastionVMIPprivate="10.0.0.5"

# VM Application Variables
export AppliName=$PreName"VM-Appli"
export AppliUserName=$BastionUserName
export AppliVMSize="Standard_D2s_v3"
export AppliVMUserData="script-vm-appli.sh"
export AppliVMIPprivate="10.0.0.6"