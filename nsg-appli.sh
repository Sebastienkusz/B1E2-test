#!/bin/bash

#NSG VM Application Variables
NsgAppliName=$PreName"NSG-Appli"

# Create a network security group for Application
az network nsg create \
  --resource-group $ResourceGroup \
  --name $NsgAppliName