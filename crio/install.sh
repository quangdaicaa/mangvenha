OS=Debian_Testing
VERSION=1.17
apt update
apt install -y gnupg curl
CRIO_REPO1=https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/
CRIO_REPO2=http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/
CRIO_KEY1=https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/Release.key
CRIO_KEY2=https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key
echo "deb $CRIO_REPO1 /" > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
echo "deb $CRIO_REPO2 /" > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.list
wget -O - $CRIO_KEY1 | apt-key add -
wget -O - $CRIO_KEY2 | apt-key add -
apt update
apt install -y cri-o cri-o-runc