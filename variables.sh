#!/bin/bash

# Variables
# Resource Group
ResourceGroup="Sebastien_K"
Location="westeurope"
Zone="3"
PreName="W-B1E2-"

# Virtual Network
VNet=$PreName"Network"
AdresseStart="10.0.2.0"
NetworkRange="/16"

# Subnet
Subnet=$PreName"Subnet-Nextcloud"
SubnetRange="/29"