#!/bin/bash -x

sudo apt update
sudo apt -y install wget
sudo apt -y install bzip2

sudo sed 's/#Port 22/Port 10022/g' -i /etc/ssh/sshd_config
sudo systemctl restart sshd

echo "Host appli
  Hostname 10.0.0.5
  User appli" > /home/sebastien/.ssh/config