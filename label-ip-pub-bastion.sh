#!/bin/bash

# Label Public IP VM Bastion Variables
LabelBastionIPName="esan-preproduction-bastion"

# Label Public IP VM Bastion Update
az network public-ip update \
 --resource-group $ResourceGroup \
 –name $BastionIPName \
 --dns-name $LabelBastionIPName \
 --allocation-method Static