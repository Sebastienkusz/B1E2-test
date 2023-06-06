#!/bin/bash

#Data Disk VM Application Variables
DataDiskAppli=$PreName"VM-Appli-Data-Disk"
# E6 for 64 Go SSD Standard
DataDiskAppliSize="E6"

az disk create \
  –resource-group $ResourceGroup \
  –name $DataDiskAppli \
  –architecture x64 \
  –os-type linux \
  –sku Standard_LRS
  –tier $DataDiskAppliSize
  –zone $Zone