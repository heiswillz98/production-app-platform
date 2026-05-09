#!/bin/bash
# EC2 Provisioning Script for DevOps Assessment Application

set -e

echo "Starting EC2 provisioning for DevOps Assessment Application..."

# Update system
echo "Updating system packages..."
apt-get update -y

# Install Docker
echo "Installing Docker..."
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --batch --yes --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Start and enable Docker
systemctl start docker
systemctl enable docker

# Add ubuntu user to docker group
usermod -a -G docker ubuntu

# Install AWS CLI v2
echo "Installing AWS CLI v2..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip -o /tmp/awscliv2.zip -d /tmp
/tmp/aws/install --update
rm -rf /tmp/aws /tmp/awscliv2.zip

# Ensure AWS CLI is in PATH
echo "export PATH=/usr/local/bin:\$PATH" >> /etc/profile
echo "export PATH=/usr/local/bin:\$PATH" >> /home/ubuntu/.bashrc

# Install additional tools
echo "Installing additional tools..."
apt-get install -y jq unzip wget

# Create application directory
echo "Creating application directory..."
mkdir -p /opt/devops-assessment
chown ubuntu:ubuntu /opt/devops-assessment

# Create logs directory
mkdir -p /opt/devops-assessment/logs
chown ubuntu:ubuntu /opt/devops-assessment/logs

# Install CloudWatch agent
echo "Installing CloudWatch agent..."
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i amazon-cloudwatch-agent.deb || apt-get install -f -y
rm -f amazon-cloudwatch-agent.deb

# Create CloudWatch agent configuration
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << 'EOF'
{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "cwagent"
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/opt/devops-assessment/logs/*.log",
            "log_group_name": "/devops-assessment/app",
            "log_stream_name": "{instance_id}",
            "timezone": "UTC"
          }
        ]
      }
    }
  },
  "metrics": {
    "namespace": "CWAgent",
    "metrics_collected": {
      "cpu": {
        "measurement": [
          "cpu_usage_idle",
          "cpu_usage_iowait",
          "cpu_usage_user",
          "cpu_usage_system"
        ],
        "metrics_collection_interval": 60
      },
      "disk": {
        "measurement": [
          "used_percent"
        ],
        "metrics_collection_interval": 60,
        "resources": [
          "*"
        ]
      },
      "diskio": {
        "measurement": [
          "io_time"
        ],
        "metrics_collection_interval": 60,
        "resources": [
          "*"
        ]
      },
      "mem": {
        "measurement": [
          "mem_used_percent"
        ],
        "metrics_collection_interval": 60
      }
    }
  }
}
EOF

# Start CloudWatch agent
systemctl enable amazon-cloudwatch-agent
systemctl start amazon-cloudwatch-agent

# Create deployment script
cat > /opt/devops-assessment/deploy.sh << 'EOF'
#!/bin/bash
set -e

ECR_REGISTRY="$1"
IMAGE_TAG="$2"

if [ -z "$ECR_REGISTRY" ] || [ -z "$IMAGE_TAG" ]; then
    echo "Usage: $0 <ECR_REGISTRY> <IMAGE_TAG>"
    exit 1
fi

echo "Deploying application from $ECR_REGISTRY:$IMAGE_TAG"

# Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR_REGISTRY

# Stop existing container
docker stop devops-assessment-app 2>/dev/null || true
docker rm devops-assessment-app 2>/dev/null || true

# Pull new image
docker pull $ECR_REGISTRY:$IMAGE_TAG

# Run new container
docker run -d \
    --name devops-assessment-app \
    --restart unless-stopped \
    -p 3000:3000 \
    -v /opt/devops-assessment/logs:/app/logs \
    -e NODE_ENV=production \
    -e PORT=3000 \
    -e LOG_LEVEL=info \
    $ECR_REGISTRY:$IMAGE_TAG

echo "Deployment completed successfully!"
echo "Application is running on port 3000"
EOF

chmod +x /opt/devops-assessment/deploy.sh
chown ubuntu:ubuntu /opt/devops-assessment/deploy.sh

# Create health check script
cat > /opt/devops-assessment/health-check.sh << 'EOF'
#!/bin/bash

# Check if container is running
if ! docker ps | grep -q devops-assessment-app; then
    echo "ERROR: Application container is not running"
    exit 1
fi

# Check if application is responding
if ! curl -f http://localhost:3000/health >/dev/null 2>&1; then
    echo "ERROR: Application health check failed"
    exit 1
fi

echo "Application is healthy"
exit 0
EOF

chmod +x /opt/devops-assessment/health-check.sh
chown ubuntu:ubuntu /opt/devops-assessment/health-check.sh

echo ""
echo "=========================================="
echo "EC2 Provisioning Completed Successfully!"
echo "=========================================="
echo ""
echo "Application directory: /opt/devops-assessment"
echo "Deployment script: /opt/devops-assessment/deploy.sh"
echo "Health check script: /opt/devops-assessment/health-check.sh"
echo "Logs directory: /opt/devops-assessment/logs"
echo ""
echo "Next steps:"
echo "1. Deploy application: /opt/devops-assessment/deploy.sh <ECR_REGISTRY> <IMAGE_TAG>"
echo "2. Check health: /opt/devops-assessment/health-check.sh"
echo "3. View logs: docker logs devops-assessment-app"
echo ""
