#!/bin/bash

#Public IP VM Bastion Variables
BastionIPName=$PreName"VM-Bastion-IP"

#Public IP VM Bastion Creation
az network public-ip create \
    --resource-group $ResourceGroup \
    --name $BastionIPName \
    --version IPv4 \
    --sku Standard \
    --zone $Zone
