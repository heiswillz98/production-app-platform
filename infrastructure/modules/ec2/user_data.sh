#!/bin/bash
# Basic EC2 setup script

# Update system
apt-get update -y

# Install basic packages
apt-get install -y curl unzip jq

# Create application directory
mkdir -p /opt/${project_name}
chown ubuntu:ubuntu /opt/${project_name}

echo "Basic EC2 setup completed for ${project_name}"
