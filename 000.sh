#!/bin/bash

# Variables
# Resource Group
export ResourceGroup="Sebastien_K"
export Location="westeurope"
export Zone="3"
export PreName="W-B1E2-"

# Virtual Network
export VNet=$PreName"Network"
export AdresseStart="10.0.0.0"
export NetworkRange="/16"

# Subnet
export Subnet=$PreName"Subnet-Nextcloud"
export SubnetRange="/28"

# NSG VM Bastion Variables
export NsgBastionName=$PreName"NSG-Bastion"

#NSG Rules VM Bastion Variables
export NsgBastionRules=$PreName"NSG-Rules-Bastion"
export NsgBastionRuleSSHPort="10022"

#NSG VM Application Variables
export NsgAppliName=$PreName"NSG-Appli"


#NSG Rules VM Appli Variables
export NsgAppliRules=$PreName"NSG-Rules-Appli"

# Network Interface Card Variables
export Nic=$PreName"Nic"

#Public IP VM Bastion Variables
export BastionIPName=$PreName"VM-Bastion-IP"

#Public IP VM Application Variables
export AppliIPName=$PreName"VM-Appli-IP"

# Label Public IP VM Bastion Variables - Record DNS
export LabelBastionIPName="esan-preproduction-bastion"

# Label Public IP VM Application Variables - Record DNS
export LabelAppliIPName="esan-preproduction-nextcloud"

# RSA SSH Creation
export SshKeyName=$PreName"Nextcloud"

# OS Disk VM Bastion
export OSDiskBastion=$PreName"VM-Bastion-OS-Disk"
export OSDiskBastionSizeGB="30"

# OS Disk VM Application
export OSDiskAppli=$PreName"VM-Appli-OS-Disk"
export OSDiskAppliSizeGB="30"

#Data Disk VM Application Variables
export DataDiskAppli=$PreName"VM-Appli-Data-Disk"
export DataDiskAppliSizeGB="64"
export DataDiskAppliSku="StandardSSD_LRS"

# VM Bastion Variables
export BastionName=$PreName"VM-Bastion"
export ImageOs="Ubuntu2204"	# 0001-com-ubuntu-server-focal:22_04-lts-gen2
export BastionVMSize="Standard_B2s"
export BastionVMUserData="script-vm-bastion.sh"
export BastionVMIPprivate="10.0.0.5"

# VM Application Variables
export AppliName=$PreName"VM-Appli"
export AppliUserName=$BastionUserName
export AppliVMSize="Standard_D2s_v3"
export AppliVMUserData="script-vm-appli.sh"
export AppliVMIPprivate="10.0.0.6"



# Prompt ask informations
read -p "Nom de l'administrateur principal (uniquement des petites lettres et sans accent) : " BastionUserName
read -p "Adresse e-mail de l'administrateur principal : " SshKeyMail
read -p "Nombre d'administrateurs à ajouter : " NumberAdmin

echo "Pour se connecter au bastion : "
echo "ssh "$BastionUserName"\@"$LabelBastionIPName".westeurope.cloudapp.azure.com"





# User Data for VM Bastion Creation script
echo -e "#!/bin/bash -x

sudo apt update

sudo sed 's/#Port 22/Port 10022/g' -i /etc/ssh/sshd_config
sudo systemctl restart sshd

echo -e \"Host appli
  Hostname "$AppliVMIPprivate"
\" > /home/"$BastionUserName"/.ssh/config" > $BastionVMUserData


# User Data for VM Appli Creation script
echo -e "#!/bin/bash -x

sudo apt update
sudo apt -y install wget
sudo apt -y install bzip2

# Apache installation
sudo apt -y install apache2
sudo apt -y install php libapache2-mod-php php-mysql php-xml php-cli php-gd php-curl php-zip php-mbstring php-bcmath

# Application installation
sudo wget -O /tmp/latest.tar.bz2 https://download.nextcloud.com/server/releases/latest.tar.bz2
sudo tar -xjvf /tmp/latest.tar.bz2 -C /tmp
sudo mv /tmp/nextcloud /var/www/
sudo chown -R www-data:www-data /var/www/nextcloud

echo \"<VirtualHost *:80>
  ServerAdmin webmaster@localhost
  DocumentRoot /var/www/nextcloud
  ErrorLog ${APACHE_LOG_DIR}/error.log
  CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>\" > /etc/apache2/sites-available/nextcloud.conf

# Configuration
sudo a2dissite 000-default.conf
sudo a2ensite nextcloud.conf
sudo systemctl restart apache2

sudo awk '{ print } \"0 =>\" { print \"1 => '"$LabelAppliIPName".westeurope.cloudapp.azure.com',\" }' /var/www/nextcloud/config/config.php" > $AppliVMUserData


# Add more administrators with ssh keys

if [ $NumberAdmin -gt 0 ]
then
    AdminArray=()
    for (( i=1; i<=$NumberAdmin; i++))
    do
        read -p "Nom d'administrateur pour la personne ( $i ) : " UserNameTmp
        read -p "Nom du fichier de sa clé publique : " KeyNameTmp
        if [ ! -f $KeyNameTmp]
        then
            while [ ! -f $KeyNameTmp]
                do
                    read -p "Mauvais Nom du fichier de sa clé publique - recommencez : " KeyNameTmp
                done
        fi
        ssh $LabelBastionIPName "sudo adduser --gecos '' --disabled-password "$UserNameTmp
        Groupes=$(groups $BastionUserName | sed "s/"$BastionUserName" : //" | sed "s/"$BastionUserName" //" | sed "s/ /,/g")
        sudo usermod -a -G $Groupes $UserNameTmp
        KeyVarTmp=$(cat $KeyNameTmp)
        sudo ssh -J $LabelBastionIPName $BastionUserName@$BastionVMIPprivate echo $KeyVarTmp >> "/home/"$UserNameTmp"/authorized_keys"
        sudo ssh -J $LabelBastionIPName $BastionUserName@$BastionVMIPprivate sudo chmod 644 "/home/"$UserNameTmp"/authorized_keys"
        
        # sudo ssh-copy-id -i $KeyNameTmp $LabelBastionIPName
        # KeyVarTmp="echo 'cat "$KeyNameTmp"'"
        # sudo ssh -J $LabelBastionIPName $BastionUserName@$BastionVMIPprivate echo $KeyVarTmp >> 
    done
fi

# Virtual Network and subnet Creation
echo "Virtual Network and subnet Creation"
az network vnet create \
  --name $VNet \
  --resource-group $ResourceGroup \
  --address-prefix $AdresseStart$NetworkRange \
  --subnet-name $Subnet \
  --subnet-prefixes $AdresseStart$SubnetRange

# Create a network security group for Bastion
echo "Create a network security group for Bastion"
az network nsg create \
  --resource-group $ResourceGroup \
  --name $NsgBastionName 

# Create Rules in network security group for Bastion
echo "Create Rules in network security group for Bastion"
az network nsg rule create \
  --resource-group $ResourceGroup \
  --nsg-name $NsgBastionName \
  --name Allow-SSH-All \
  --access Allow \
  --protocol Tcp \
  --direction Inbound \
  --priority 110 \
  --source-port-range "*" \
  --destination-port-range $NsgBastionRuleSSHPort

# Create a network security group for Application
echo "Create a network security group for Application"
az network nsg create \
  --resource-group $ResourceGroup \
  --name $NsgAppliName

# Create Rules in network security group for Application
echo "Create Rules in network security group for Application"
az network nsg rule create \
  --resource-group $ResourceGroup \
  --nsg-name $NsgAppliName \
  --name Allow-SSH-All \
  --access Allow \
  --protocol Tcp \
  --direction Inbound \
  --priority 110 \
  --source-address-prefix "*" \
  --source-port-range "*" \
  --destination-port-range 22

az network nsg rule create \
  --resource-group $ResourceGroup \
  --nsg-name $NsgAppliName \
  --name Allow-HTTP-All \
  --access Allow \
  --protocol Tcp \
  --direction Inbound \
  --priority 1000 \
  --source-address-prefix "*" \
  --source-port-range "*" \
  --destination-port-range 80

az network nsg rule create \
  --resource-group $ResourceGroup \
  --nsg-name $NsgAppliName \
  --name Allow-HTTPS-All \
  --access Allow \
  --protocol Tcp \
  --direction Inbound \
  --priority 1010 \
  --source-address-prefix "*" \
  --source-port-range "*" \
  --destination-port-range 443

# Network Interface Card Creation
echo "Public IP VM Bastion Creation"
az network nic create \
    --resource-group $ResourceGroup \
    --name $Nic \
    --vnet-name $VNet \
    --subnet $Subnet

#Public IP VM Bastion Creation
echo "Public IP VM Bastion Creation"
az network public-ip create \
    --resource-group $ResourceGroup \
    --name $BastionIPName \
    --version IPv4 \
    --sku Standard \
    --zone $Zone

#Public IP VM Application Creation
echo "Public IP VM Application Creation"
az network public-ip create \
    --resource-group $ResourceGroup \
    --name $AppliIPName \
    --version IPv4 \
    --sku Standard \
    --zone $Zone

# Label Public IP VM Bastion Update
echo "Label Public IP VM Bastion Update"
az network public-ip update \
 --resource-group $ResourceGroup \
 --name $BastionIPName \
 --dns-name $LabelBastionIPName \
 --allocation-method Static

# Label Public IP VM Application Update
echo "Label Public IP VM Application Update"
az network public-ip update \
 --resource-group $ResourceGroup \
 --name $AppliIPName \
 --dns-name $LabelAppliIPName \
 --allocation-method Static

# Generate SSH Key
ssh-keygen -t rsa -b 4096 -N '' -C $SshKeyMail -f "/home/$USER/.ssh/"$SshKeyName"_rsa"

# SSH Config file Create/Add
if [ ! -e $HOME/.ssh/config ] || !(grep "$LabelBastionIPName" $HOME/.ssh/config) ; then
    echo -e "
Host "$LabelBastionIPName"
  Hostname "$LabelBastionIPName".westeurope.cloudapp.azure.com
  User "$BastionUserName"
  Port "$NsgBastionRuleSSHPort"
  IdentityFile "$HOME"/.ssh/"$SshKeyName"_rsa
  ForwardAgent yes
  " >> $HOME/.ssh/config
fi

# Data Disk VM Application Creation
echo "Data Disk VM Application Creation"
az disk create \
  --resource-group $ResourceGroup \
  --name $DataDiskAppli \
  --architecture "x64" \
  --encryption-type "EncryptionAtRestWithPlatformKey" \
  --size-gb $DataDiskAppliSizeGB \
  --sku $DataDiskAppliSku \
  --disk-iops-read-write 500 \
  --disk-mbps-read-write 60 \
  --zone $Zone

#VM Bastion Creation
echo "VM Bastion Creation"
az vm create \
  --resource-group $ResourceGroup \
  --name $BastionName \
  --location $Location \
  --size $BastionVMSize \
  --image $ImageOs \
  --os-disk-name $OSDiskBastion \
  --os-disk-delete-option "Detach" \
  --os-disk-size-gb $OSDiskBastionSizeGB \
  --custom-data $BastionVMUserData \
  --vnet-name $VNet \
  --subnet $Subnet \
  --private-ip-address $BastionVMIPprivate \
  --nsg $NsgBastionName \
  --public-ip-address $BastionIPName \
  --admin-username $BastionUserName \
  --ssh-key-values "/home/$USER/.ssh/"$SshKeyName"_rsa.pub" \
  --zone $Zone 

#VM Application Creation
az vm create \
  --resource-group $ResourceGroup \
  --attach-data-disks $DataDiskAppli \
  --name $AppliName \
  --location $Location \
  --size $AppliVMSize \
  --image $ImageOs \
  --os-disk-name $OSDiskAppli \
  --os-disk-delete-option "Detach" \
  --os-disk-size-gb $OSDiskAppliSizeGB \
  --custom-data $AppliVMUserData \
  --vnet-name $VNet \
  --subnet $Subnet\
  --private-ip-address $AppliVMIPprivate \
  --nsg $NsgAppliName \
  --public-ip-address $AppliIPName \
  --admin-username $AppliUserName \
  --ssh-key-values "/home/$USER/.ssh/"$SshKeyName"_rsa.pub" \
  --zone $Zone

# Add ssh ket to ssh agent
eval "$(ssh-agent -s)"
ssh-add "/home/$USER/.ssh/"$SshKeyName"_rsa"
