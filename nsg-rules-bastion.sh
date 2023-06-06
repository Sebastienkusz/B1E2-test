#!/bin/bash

#NSG Rules VM Bastion Variables
NsgBastionRules=$PreName"NSG-Rules-Bastion"

# Create Rules in network security group for Bastion
az network nsg rule create \
  --resource-group $ResourceGroup \
  --nsg-name $NsgBastionName \
  --name Allow-SSH-All \
  --access Allow \
  --protocol Tcp \
  --direction Inbound \
  --priority 110 \
  --source-address-prefix Internet \
  --source-port-range "*" \
  --destination-asgs $NsgBastionRules \
  --destination-port-range 10022
