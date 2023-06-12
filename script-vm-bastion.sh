#!/bin/bash -x

sudo apt update

sudo sed 's/#Port 22/Port 10022/g' -i /etc/ssh/sshd_config
sudo systemctl restart sshd

echo -e "Host appli
  Hostname 10.0.0.6
" > /home/sebastien/.ssh/config
