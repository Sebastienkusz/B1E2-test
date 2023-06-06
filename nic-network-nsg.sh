#!/bin/bash

#Public IP VM Bastion Variables
az network vnet subnet update \
    --resource-group $ResourceGroup \
    --vnet-name $VNet \
    --name $Subnet \
    --network-security-group $NsgBastionRules