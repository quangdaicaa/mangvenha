#!/usr/bin/bash

# ssh root@217.76.56.249
# qAzplm@13579

NAME=217.76.56.249

apt update
apt install -y git
git clone https://github.com/quangdaicaa/SetupServer.git

mkdir -p ~/.ssh
cp ~/SetupServer/config/ssh/sshd_config /etc/ssh/sshd_config
cp ~/SetupServer/config/ssh/$NAME.pub ~/.ssh/authorized_keys
chmod 700 ~
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
systemctl restart sshd
rm -rf ~/SetupServer
exit