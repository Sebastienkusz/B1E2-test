#!/bin/bash

# Key Vault Variables
KeyVaultName=$PreName"KeyVault"

# Key Vault Creation
az keyvault create \
  --resource-group $ResourceGroup \
  --location $Location \
  --name $KeyVaultName \
  --enabled-for-disk-encryption
#–secure-vm-disk-encryption-set