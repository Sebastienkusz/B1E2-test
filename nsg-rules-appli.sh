#!/bin/bash

#NSG Rules VM Appli Variables
NsgAppliRules=$PreName"NSG-Rules-Appli"

# Create Rules in network security group for Application
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
  --destination-asgs $NsgAppliRules \
  --destination-port-range 22
