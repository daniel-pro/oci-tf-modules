#!/bin/bash

### Send stdout and stderr to /var/log/cloud-init2.log
exec 1> /var/log/cloud-init2.log 2>&1

touch /home/opc/CLOUD-INIT

echo "==========> Installing prereq packages for ZDM <=========="
yum install -y oraclelinux-developer-release-el8 libnsl perl unzip glibc-devel expect libaio ncurses-compat-libs ncurses-devel numactl-libs openssl mlocate bind-utils

echo "==========> Creating ZDM user and group <=========="
groupadd zdm
useradd -g zdm zdmuser

echo "==========> Creating ZDM home and base directories <=========="
mkdir -p /u01/app/zdmhome /u01/app/zdmbase
chown zdmuser:zdm /u01/app/zdmhome /u01/app/zdmbase

echo "==========> Apply latest updates to Linux OS <=========="
yum update -y

echo "==========> Final reboot <=========="
reboot
