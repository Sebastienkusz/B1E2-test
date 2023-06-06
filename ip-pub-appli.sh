#!/bin/bash

#Public IP VM Application Variables
AppliIPName=$PreName"VM-Appli-IP"

#Public IP VM Application Creation
az network public-ip create \
    --resource-group $ResourceGroup \
    --name $AppliIPName \
    --version IPv4 \
    --sku Standard \
    --zone $Zone