#!/bin/bash
BastionVMUserData="script-vm-bastion.sh"
BastionUserName="sebastien"
AppliVMIPprivate="10.0.0.6"

# User Data Creation script
echo -e "
#!/bin/bash -x

sudo apt update

sudo sed 's/#Port 22/Port 10022/g' -i /etc/ssh/sshd_config
sudo systemctl restart sshd

echo -e \"
Host appli
  Hostname "$AppliVMIPprivate"
\" > /home/"$BastionUserName"/.ssh/config
" > $BastionVMUserData

cat $BastionVMUserData