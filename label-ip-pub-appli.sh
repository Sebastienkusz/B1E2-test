#!/bin/bash

# Label Public IP VM Application Variables
LabelAppliIPName="esan-preproduction-nextcloud"

# Label Public IP VM Application Update
az network public-ip update \
 --resource-group $ResourceGroup \
 –name $AppliIPName \
 --dns-name $LabelAppliIPName \
 --allocation-method Static