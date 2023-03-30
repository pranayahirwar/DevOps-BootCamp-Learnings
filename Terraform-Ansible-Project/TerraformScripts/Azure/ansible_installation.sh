#!/bin/bash

# Check for latest pip3 update
pip3 install --upgrade pip

# Check for python3 installation, install if not present
if ! command -v python3 &> /dev/null
then
    echo "Python3 not found. Installing Python3..."
    apt-get update
    apt-get install -y python3
fi

# Install Ansible
echo "Installing Ansible..."
apt-get update
apt-get install -y ansible
