#!/bin/bash

# Add more administrators with ssh keys
read -p "Nombre d'administrateurs à ajouter : " NumberAdmin
if [ $NumberAdmin -gt 0 ]
then
    AdminArray=()
    for (( i=1; i<=$NumberAdmin; i++))
    do
        read -p "Nom d'administrateur pour la personne ( $i ) : " UserNameTmp
        read -p "Nom du fichier de sa clé publique : " KeyNameTmp
        if [ ! -f $KeyNameTmp]
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