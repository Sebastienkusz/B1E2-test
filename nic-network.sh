#!/bin/bash

#Public IP VM Bastion Variables
Nic=$PreName"Nic"

#Public IP VM Bastion Creation
az network nic create \
    --resource-group $ResourceGroup \
    --name $Nic \
    --vnet-name $VNet \
    --subnet $Subnet