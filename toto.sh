#!/bin/zsh -x

Usertest="seb"

popo=$(groups $Usertest | sed 's/'$Usertest' : //' | sed 's/'$Usertest' //' | sed 's/ /,/g')

echo $popo