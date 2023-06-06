#!/bin/bash

#OS Disk VM Bastion Variables
OSDiskBastion=$PreName"VM-Bastion-OS-Disk"
# S4 for 32 Go HDD Standard
OSDiskBastionSize="S4"

az disk create \
  –resource-group $ResourceGroup \
  –name $OSDiskBastion \
  –architecture x64 \
  –os-type linux \
  –sku Standard_LRS \
  –tier $OSDiskBastionSize \
  –zone $Zone