#!/usr/bin/zsh

NAME=217.76.56.249
SSH_CONF=$CONFIG/sshd_config
PUB_KEY=$CONFIG/$NAME/ssh.pub

mkdir -p ~/.ssh
cp $SSH_CONF /etc/ssh/sshd_config
cp $PUB_KEY ~/.ssh/authorized_keys
chmod 700 ~
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
systemctl restart sshd
