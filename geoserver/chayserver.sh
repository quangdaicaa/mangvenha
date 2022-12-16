#!/usr/bin/zsh

rm ~/.ssh/known_hosts
rm ~/.ssh/known_hosts.old

# ssh root@217.76.52.157
# yes
# qAzplm@13579
# chmod 600 ~/.ssh/id_rsa

cd ~
NAME=217.76.52.157
CONFIG=~/configGeo/config
GIT=https://github.com/quangdaicaa/configGeo.git
apt update
apt install -y git
git clone $GIT
chmod +x $CONFIG/build1.sh
chmod +x $CONFIG/build2.sh

# --------------------
mkdir -p ~/.ssh
cp $CONFIG/sshd_config /etc/ssh/sshd_config
cp $CONFIG/$NAME/ssh.pub ~/.ssh/authorized_keys
chmod 700 ~
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
systemctl restart sshd
