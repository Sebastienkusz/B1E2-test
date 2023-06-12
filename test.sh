#!/bin/bash
ResourceGroup="Sebastien_K"
BastionVMUserData="script-vm-bastion.sh"

az vm run-command invoke \
  --resource-group $ResourceGroup \
  --name "W-B1E2-VM-Bastion" \
  --command-id RunShellScript \
  --scripts @script-vm-bastion.sh
