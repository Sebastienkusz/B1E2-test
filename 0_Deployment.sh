#!/bin/bash
./00_Variables.sh


# Prompt ask informations
read -p "Nom de l'administrateur principal (uniquement des petites lettres et sans accent) : " BastionUserName
read -p "Adresse e-mail de l'administrateur principal : " SshKeyMail
read -p "Nombre d'administrateurs à ajouter : " NumberAdmin

export BastionUserName
export SshKeyMail
export NumberAdmin

# Run Generation scripts
source 1_GenScripts.sh

# Run Add Users
# ./2_AddUsers.sh

# Run infrastructure
source 3_Infrastructure.sh

# Run last config
source 4_Config.sh

echo "Pour se connecter au bastion : "
echo "ssh "$BastionUserName"\@"$LabelBastionIPName".westeurope.cloudapp.azure.com"