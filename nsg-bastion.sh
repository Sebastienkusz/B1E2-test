#!/bin/bash

#NSG VM Bastion Variables
NsgBastionName=$PreName"NSG-Bastion"

# Create a network security group for Bastion
az network nsg create \
  --resource-group $ResourceGroup \
  --name $NsgBastionName
