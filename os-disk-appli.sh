#!/bin/bash

#OS Disk VM Application Variables
OSDiskAppli=$PreName"VM-Appli-OS-Disk"
# E4 for 32 Go SSD Standard
OSDiskAppliSize="E4"

az disk create \
  –resource-group $ResourceGroup \
  –name $OSDiskAppli \
  –architecture x64 \
  –os-type linux \
  –sku Standard_LRS \
  –tier $OSDiskAppliSize \
  –zone $Zone