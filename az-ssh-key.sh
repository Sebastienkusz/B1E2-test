#!/bin/bash

# SSH key Variables
SshKey=$PreName"VM-SSH-key"

# SSH Key Creation
az sshkey create \
  –location $Location \
  –public-key “{ssh-rsa public key}” \
  –resource-group $ResourceGroup \
  –name $SshKey