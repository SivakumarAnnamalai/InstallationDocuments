## NB12-Oracle Realtime

## install postgres
sudo yum install postgresql-server postgresql-contrib -y
sudo postgresql-setup initdb

## start postgres
sudo systemctl start postgresql
sudo systemctl enable postgresql

## change linux user "postgres" password
sudo passwd postgres

## change the postgres mysql password
su - postgres
psql -d template1 -c "ALTER USER postgres WITH PASSWORD 'newpassword';"

## login into postgres sql
psql postgres

createdb mytestdb
psql mytestdb

\l

yum install wget vim -y
wget -nv http://public-repo-1.hortonworks.com/ambari/centos7-ppc/2.x/updates/2.6.0.0/ambari.repo -O /etc/yum.repos.d/ambari.repo
yum install ambari-server
ambari-server setup
ambari-server start

sudo su postgres
psql


create database registry;
CREATE USER registry WITH PASSWORD 'registry';
GRANT ALL PRIVILEGES ON DATABASE "registry" to registry;

wget https://s3.amazonaws.com/public-repo-1.hortonworks.com/HDF/centos7/3.x/updates/3.0.2.0/tars/hdf_ambari_mp/hdf-ambari-mpack-3.0.2.0-76.tar.gz
ambari-server install-mpack --mpack=/root/hdf-ambari-mpack-3.0.2.0-76.tar.gz --purge --verbose
ambari-server restart

