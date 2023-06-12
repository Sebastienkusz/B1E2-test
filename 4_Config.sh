#!/bin/bash

# Change ssh keys permissions
sudo chmod 600 /home/$USER/.ssh/"$SshLocateKeyName"_rsa
sudo chmod 644 /home/$USER/.ssh/"$SshLocateKeyName"_rsa.pub

# Add ssh ket to ssh agent
eval "$(ssh-agent -s)"
ssh-add "/home/$USER/.ssh/"$SshKeyName"_rsa"

