#!/bin/bash
###########################################
################ Variables ################
###########################################
HOSTNAME='working'
USERNAME='danielhand'
IPADDRESS='10.0.5.5'
NETMASK='255.255.240.0'
GATEWAY='10.0.0.1'
NAMESERVER='10.0.1.3 10.0.1.4'
PACKAGES='htop nano sudo python-minimal vim rsync dnsutils less ntp'

###########################################
################# Updates #################
###########################################
apt-get update && apt-get upgrade -y
apt-get -y dist-upgrade

###########################################
################## Apps ###################
###########################################
apt-get install $PACKAGES -y

###########################################
################## SSH ####################
###########################################

# Add SSH Key for default user
mkdir /home/$USERNAME/.ssh/
cat > /home/$USERNAME/.ssh/authorized_keys <<EOF
SSH-KEY HERE
EOF
chmod 700 /home/$USERNAME/.ssh
chmod 600 /home/$USERNAME/.ssh/authorized_keys
chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh
# Add SSH Key for root user
mkdir /root/.ssh/
cat > /root/.ssh/authorized_keys <<EOF
SSH-KEY HERE
EOF
chmod 700 /root/.ssh
chmod 600 /root/.ssh/authorized_keys
chown -R root:root /root/.ssh

# Edit /etc/ssh/sshd_config
sed -i '/^PermitRootLogin/s/prohibit-password/yes/' /etc/ssh/sshd_config
sed -i -e 's/#PasswordAuthentication/PasswordAuthentication/g' /etc/ssh/sshd_config

###########################################
################# Network #################
###########################################
mv /etc/network/interfaces /etc/network/interfaces.bk
cat > /etc/network/interfaces <<EOF
auto lo eth0
iface lo inet loopback
iface eth0 inet static
address $IPADDRESS
netmask $NETMASK
gateway $GATEWAY
dns-nameservers $NAMESERVER
EOF

###########################################
############# Change Hostname #############
###########################################
hostn=$(cat /etc/hostname)
sudo sed -i "s/$hostn/$HOSTNAME/g" /etc/hosts
sudo sed -i "s/$hostn/$HOSTNAME/g" /etc/hostname
sudo reboot
