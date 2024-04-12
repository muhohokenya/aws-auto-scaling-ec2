#!/bin/bash

# Update the package lists for upgrades and new package installations
sudo apt-get update

# Install httpd (Apache)
sudo apt-get install apache2 -y

# Echo the hostname of the VM
hostname=$(hostname)
echo "The hostname of this VM is: $hostname"

# Write the hostname to a file in the web server's root directory
echo $hostname > /var/www/html/index.html
