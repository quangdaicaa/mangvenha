apt update
apt install -y lsb-release wget gnupg
OS=$(lsb_release -cs)
PSQL_KEY=https://www.postgresql.org/media/keys/ACCC4CF8.asc
PSQL_REPO=http://apt.postgresql.org/pub/repos/apt
echo "deb $PSQL_REPO $OS-pgdg main" > /etc/apt/sources.list.d/pgdg.list
wget --no-check-certificate --quiet -O - $PSQL_KEY | apt-key add -
apt update
apt install -y postgresql
psql --version
service postgresql restart