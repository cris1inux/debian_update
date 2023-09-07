#!/bin/bash

#add google dns to /etc/resolv.conf
if ! grep -qxF 'nameserver 8.8.8.8' /etc/resolv.conf; then
  sed -i '/^nameserver 8.8.8.8/! s/^/#/' /etc/resolv.conf
  echo 'nameserver 8.8.8.8' >> /etc/resolv.conf
fi

# Add new active repositories for debian 11
echo -e "deb http://deb.debian.org/debian bullseye main contrib non-free\n\
deb http://deb.debian.org/debian bullseye-updates main contrib non-free\n\
deb http://security.debian.org/debian-security bullseye-security main contrib non-free" > /etc/apt/sources.list

# Comment the line to avoid conflicts with the update
sudo sed -i 's/^deb/# deb/' /etc/apt/sources.list.d/bird.list

# Update system
echo "Updating system..."
sudo apt-get update -y
clear

# Upgrade system und upgrade to debian 11
echo "Upgrading system..."
sudo apt-get upgrade -y
sudo apt full-upgrade -y
clear

#The updated version of strongswan does not allow points in the configuration file, we need to change it.
mv /var/log/ipsec.log /var/log/ipsec_log
sed -i 's#/var/log/ipsec.log#/var/log/ipsec_log#g' /etc/strongswan.d/charon-logging.conf

#Disable apparmor to avoid conflicts with strongswan
systemctl stop apparmor &> /dev/null
systemctl disable apparmor &> /dev/null
ipsec restart &> /dev/null

# Upgrade the kernel along with other packages
echo "Upgrading kernel..."
sudo apt-get install linux-image-amd64 -y

# Reconfigure the GRUB bootloader
sudo dpkg-reconfigure grub-pc

# Update the bootloader
sudo update-grub

echo "The system was successfully updated and upgraded to debian 11"
echo "Rebooting the system to apply the changes..."
sleep 2
reboot
