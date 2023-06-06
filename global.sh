#!/bin/bash

# Variables
resourcegroup="Sebastien_K"
location="westeurope"
VNet="W-B2-Network"
Subnet="W-B2-Subnet-Nextcloud"
AdresseStart="10.0.0.0"
NetworkRange="/16"
SubnetRange="/29"
BastionName="B2-VM-Bastion"
ImageOs="Ubuntu2204"
BastionIPname="B2-VM-Bastion-IP"
BastionUserName="nextcloud"


#Virtual Network Creation 
az network vnet create \
  --name $VNet \
  --resource-group $resourcegroup \
  --address-prefix $AdresseStart$NetworkRange \
  --subnet-name $Subnet \
  --subnet-prefixes $AdresseStart$SubnetRange

#Creation adresse ip statique Bastion
az network public-ip create \
    --resource-group $resourcegroup \
    --name $BastionIPname \
    --version IPv4 \
    --sku Standard \
    --zone 1 2 3

#Virtual Bastion Creation
az vm create \
  --resource-group $resourcegroup \
  --name $BastionName \
  --image $ImageOs \
  --public-ip-address $BastionIPname \
  --admin-username $BastionUserName \
  --no-wait




#Affichage de l'adresse IP
az network public-ip show \
    --resource-group myResourceGroup \
    --name myPublicIP \
    --query [ipAddress,publicIpAllocationMethod,sku] \
    --output table