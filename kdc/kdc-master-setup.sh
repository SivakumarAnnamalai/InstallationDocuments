## How to execute the script
## USAGE: sh /home/ec2-user/InstallationDocuments/kdc/kdc-master-setup.sh /home/ec2-user/InstallationDocuments/common/env_devint.properties
## USAGE: sh /home/ec2-user/InstallationDocuments/kdc/kdc-master-setup.sh /home/ec2-user/InstallationDocuments/common/env_devint.properties

if [ "$#" -ne 1 ]; then
  echo "Please provide right number of arguments"
  echo "Usage: sh kdc-master-setup.sh env_prop_file_location"
  echo "Example: sh /home/ec2-user/InstallationDocuments/common/kdc-master-setup.sh /home/ec2-user/InstallationDocuments/common/env_devint.properties" 
  exit 1
fi

## install necessary softwares
yum install -y krb5-server krb5-workstation vim

## Copy the templates and property files to home directory
home_dir="/home/ec2-user"
env_prop_file=$1

## source the property file
source $env_prop_file

# Required Directories
repo_dir="${home_dir}/InstallationDocuments"
common_dir="${repo_dir}/common"
kdc_dir="${repo_dir}/kdc"

## Generate the required Kerberos config files from the template and copy it to right location
sh $common_dir/template_to_original.sh $env_prop_file $kdc_dir/krb5.conf.template > /etc/krb5.conf
sh $common_dir/template_to_original.sh $env_prop_file $kdc_dir/kadm5.acl.template > /var/kerberos/krb5kdc/kadm5.acl
sh $common_dir/template_to_original.sh $env_prop_file $kdc_dir/kdc.conf.template > /var/kerberos/krb5kdc/kdc.conf
sh $common_dir/template_to_original.sh $env_prop_file $kdc_dir/principal_names.template > $kdc_dir/principal_names
sh $common_dir/template_to_original.sh $env_prop_file $kdc_dir/kdc1-network.template > /etc/sysconfig/network 

## Initialize the database for the Realm
kdb5_util -r $REALM create -s -P $KDC_MASTER_KEY

## Set runlevel and Start the Kerberos services
chkconfig --level 2345 krb5kdc on
chkconfig --level 2345 kadmin on
service krb5kdc start
service kadmin start

## Create the keytabs directory
mkdir -p $KEYTABS_DIR

## Create necessary principals and keytabs
awk -F, '{ print "addprinc  -randkey ", $1 }' < $kdc_dir/principal_names | kadmin.local
awk -F, '{ print "ktadd -k ", $2," ", $1 }' < $kdc_dir/principal_names | kadmin.local

## All the below steps are required for slave to be in sync with master
mkdir -p /misc/scripts/
#sh $common_dir/template_to_original.sh $env_prop_file $kdc_dir/kpropd.acl.template > /var/kerberos/krb5kdc/kpropd.acl
sh $common_dir/template_to_original.sh $env_prop_file $kdc_dir/kdc_dump.sh.template > /misc/scripts/kdc_dump.sh

## Rename keytab
mv $KEYTABS_DIR/kdc1.keytab /etc/krb5.keytab

## Start kprop service which will transfer the database from Master to Slave
chkconfig --level 2345 kprop on
service kprop start

## Change the permission of the keytabs files
chmod 666 $KEYTABS_DIR/*

reboot
