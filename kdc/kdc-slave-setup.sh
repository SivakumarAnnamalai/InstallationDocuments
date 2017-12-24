## How to execute the script
## USAGE: sh /home/ec2-user/microservices-config/kdc/kdc-slave-setup.sh /home/ec2-user/microservices-config/common/env_qa.properties
## USAGE: sh /home/ec2-user/microservices-config/kdc/kdc-slave-setup.sh /home/ec2-user/microservices-config/common/env_qa.properties

if [ "$#" -ne 1 ]; then
  echo "Please provide right number of arguments"
  echo "Usage: sh kdc-slave-setup.sh env_prop_file_location"
  echo "Example: sh /home/ec2-user/microservices-config/common/kdc-slave-setup.sh /home/ec2-user/microservices-config/common/env_qa.properties" 
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
repo_dir="${home_dir}/microservices-config"
common_dir="${repo_dir}/common"
kdc_dir="${repo_dir}/kdc"

## Generate the required Kerberos config files from the template and copy it to right location
sh $common_dir/template_to_original.sh $env_prop_file $kdc_dir/krb5.conf.template > /etc/krb5.conf 
sh $common_dir/template_to_original.sh $env_prop_file $kdc_dir/kadm5.acl.template > /var/kerberos/krb5kdc/kadm5.acl 
sh $common_dir/template_to_original.sh $env_prop_file $kdc_dir/kdc.conf.template > /var/kerberos/krb5kdc/kdc.conf 
sh $common_dir/template_to_original.sh $env_prop_file $kdc_dir/kdc2-network.template > /etc/sysconfig/network 

## Create the keytabs directory
mkdir -p $KEYTABS_DIR

## Initialize the database for the Realm
kdb5_util -r $REALM create -s -P $KDC_MASTER_KEY

## All the below steps are required for slave to be in sync with master
mkdir -p /nyl/scripts/
sh $common_dir/template_to_original.sh $env_prop_file $kdc_dir/kpropd.acl.template >/var/kerberos/krb5kdc/kpropd.acl 
sh $common_dir/template_to_original.sh $env_prop_file $kdc_dir/kdc_dump.sh.template >/nyl/scripts/kdc_dump.sh 

## Manual steps to be done
## Rename keytab. Copy kdc2.keytab from kdc1 host. Below keytab and the dump has to be copied from KDC master
## mv $KEYTABS_DIR/kdc2.keytab /etc/krb5.keytab

## start services and set loglevel
service kprop start
service krb5kdc start
chkconfig --level 2345 kprop on
chkconfig --level 2345 krb5kdc on
reboot