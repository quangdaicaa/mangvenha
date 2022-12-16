#!/usr/bin/zsh

WORK_HOME=~/Desktop/build_geo
cd $WORK_HOME

mkdir -p .vscode
mkdir -p .env/python
mkdir -p .env/cli
mkdir -p .ansible
mkdir -p .docker
mkdir -p .helper
mkdir -p .draft

touch .gitignore
touch README.md
touch .draft/nhap.py

# .vscode
ln -s ~/.config/Code/User/execute.py .vscode/execute.py
ln -s ~/.config/Code/User/settings.json .vscode/settings_user.json
ln -s ~/.config/Code/User/keybindings.json .vscode/keybindings_user.json
ln -s ~/.config/Code/User/fileIcons.png .vscode/fileIcons.png
ln -s ~/.config/Code/User/folderIcons.png .vscode/folderIcons.png
ln -s ~/.vscode/extensions/icons .vscode/icons

# env
ln -s ~/.config/nvim/init.vim .env/cli/init.vim
ln -s ~/.tmux.conf .env/cli/.tmux.conf
ln -s /usr/lib/python3.11/requirements.txt .env/python/requirements.txt
ln -s /usr/lib/python3.11/upgrade.sh .env/python/upgrade.sh
ln -s /usr/cloud .env/cloud
