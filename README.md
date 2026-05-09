# DevOps Assessment - Production Application Platform

A comprehensive DevOps assessment project demonstrating enterprise-grade infrastructure as code, containerization, CI/CD automation, and cloud deployment practices.

## 🏗️ Architecture Overview

### High-Level Architecture
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   GitHub Repo   │───▶│  GitHub Actions │───▶│   AWS ECR       │
│                 │    │   CI/CD Pipeline│    │ Container Registry│
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                                        │
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   End Users     │◀───│   AWS EC2       │◀───│  Docker Images  │
│                 │    │  Application    │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │
                       ┌─────────────────┐
                       │  CloudWatch     │
                       │  Monitoring     │
                       └─────────────────┘
```

### Technology Stack
- **Application**: Node.js + TypeScript + Express.js
- **Containerization**: Docker with multi-stage builds
- **Infrastructure**: Terraform (AWS)
- **CI/CD**: GitHub Actions
- **Cloud Provider**: AWS (EC2, ECR, VPC, IAM, SSM, CloudWatch)
- **Monitoring**: CloudWatch Logs & Metrics
- **Testing**: Jest Framework

### Infrastructure Components
- **VPC**: Custom network with public subnet
- **EC2**: t3.micro Ubuntu instance with automated provisioning
- **ECR**: Docker container registry with lifecycle policies
- **IAM**: Role-based access with least privilege
- **SSM**: Automated instance provisioning and configuration
- **CloudWatch**: Centralized logging and monitoring
- **Security Groups**: Configured for HTTP, HTTPS, SSH, and application traffic

## 🚀 Deployment Steps

### Prerequisites
- AWS CLI configured with appropriate permissions
- Terraform installed locally
- Docker installed locally
- GitHub account with repository access

### 1. Infrastructure Deployment
```bash
# Navigate to infrastructure
cd infrastructure/environments/production

# Initialize Terraform
terraform init

# Plan deployment
terraform plan -var-file="terraform.tfvars"

# Apply infrastructure
terraform apply -var-file="terraform.tfvars"
```

### 2. GitHub Actions Configuration
1. **Repository Secrets** (in GitHub Settings → Secrets and variables → Actions → Secrets):
   - `AWS_ACCESS_KEY_ID`: Your AWS access key
   - `AWS_SECRET_ACCESS_KEY`: Your AWS secret key

2. **Repository Variables** (in GitHub Settings → Secrets and variables → Actions → Variables):
   - `AWS_REGION`: `us-east-1`
   - `ECR_REGISTRY`: `828659494109.dkr.ecr.us-east-1.amazonaws.com`
   - `ECR_REPOSITORY`: `devops-assessment-prod-repository`
   - `EC2_HOST`: `<EC2_PUBLIC_IP>` (from terraform output)

### 3. Automated Deployment
- Push code to `main` branch to trigger automated deployment
- GitHub Actions will: test → build → push → deploy → health check
- Monitor deployment progress in GitHub Actions tab

### 4. Manual Application Deployment (Optional)
```bash
# SSH into EC2 instance
ssh -i your-key.pem ubuntu@<EC2_PUBLIC_IP>

# Deploy manually using the installed script
/opt/devops-assessment/deploy.sh <ECR_REGISTRY> <IMAGE_TAG>
```

## 🎯 Design Decisions

### Infrastructure as Code (Terraform)
- **Modular Design**: Separated concerns into reusable modules (VPC, EC2, IAM, SSM, ECR)
- **Environment-Specific**: Separate configurations for different environments
- **State Management**: Local state for assessment simplicity (production would use S3 + DynamoDB)

### Container Strategy
- **Multi-stage Builds**: Optimize image size and security
- **Non-root User**: Security best practice for container execution
- **Health Checks**: Built-in application health endpoints

### CI/CD Pipeline
- **Dynamic Discovery**: No hardcoded infrastructure dependencies
- **Security**: Separate secrets and variables management
- **Validation**: Comprehensive testing and health checks
- **Rollback Ready**: Tagged Docker images enable easy rollback

### Monitoring & Observability
- **Structured Logging**: JSON format with correlation IDs
- **Centralized Logs**: CloudWatch integration
- **Metrics Collection**: CPU, memory, disk, and application metrics
- **Health Monitoring**: Automated health checks with alerting

## 📋 Assumptions Made

### Technical Assumptions
- AWS account with appropriate permissions
- Ubuntu 22.04 LTS AMI availability in us-east-1
- Docker Hub and AWS ECR accessibility
- GitHub Actions runner access to AWS services

### Security Assumptions
- IAM policies follow least privilege principle
- Network access is properly configured
- Secrets are managed securely in GitHub
- Container images are scanned for vulnerabilities

### Operational Assumptions
- Single-region deployment (us-east-1)
- Single-instance deployment (assessment scope)
- Manual infrastructure updates via Terraform
- Automated application updates via CI/CD

## ⚠️ Limitations

### Current Limitations
1. **Single Region**: Deployed only in us-east-1
2. **Single Instance**: No high availability or load balancing
3. **Manual Infrastructure**: Requires manual Terraform operations
4. **Local State**: Terraform state stored locally (not production-ready)
5. **Basic Monitoring**: No advanced alerting or dashboards
6. **No Database**: Stateless application only

### Scalability Considerations
- **Horizontal Scaling**: Would require load balancer and auto-scaling
- **Multi-Region**: Would need cross-region deployment strategy
- **Database**: Would need RDS or DynamoDB integration
- **Caching**: Would need Redis or ElastiCache integration

## 🔧 Potential Improvements

### Infrastructure Improvements
1. **State Management**: Implement S3 + DynamoDB for Terraform state
2. **Multi-Environment**: Add staging and development environments
3. **High Availability**: Add load balancer and multiple AZs
4. **Auto Scaling**: Implement based on metrics
5. **Backup Strategy**: Add automated backups and disaster recovery

### Security Enhancements
1. **VPC Endpoints**: Private connectivity to AWS services
2. **WAF Integration**: Web Application Firewall
3. **Certificate Management**: ACM for SSL/TLS
4. **Secrets Manager**: Replace hardcoded values with AWS Secrets Manager
5. **Audit Logging**: CloudTrail for compliance

### Monitoring & Observability
1. **Custom Dashboards**: CloudWatch dashboards for visualization
2. **Alerting**: SNS notifications for critical issues
3. **APM Integration**: Application Performance Monitoring
4. **Log Analysis**: Advanced log processing and analysis
5. **Distributed Tracing**: Request tracking across services

### CI/CD Enhancements
1. **Multi-Stage Deployments**: Blue-green or canary deployments
2. **Rollback Automation**: Automatic rollback on health check failures
3. **Security Scanning**: Container and code security scanning
4. **Performance Testing**: Load testing in pipeline
5. **Compliance Checks**: Policy as code integration
6. **Terraform CI/CD**: Automated infrastructure deployment with validation
   - Terraform plan validation in pull requests
   - Automated infrastructure testing
   - State management and locking
   - Infrastructure drift detection
   - Multi-environment deployment automation

## 📊 Project Structure

```

├── application/                    # Node.js application
│   ├── src/
│   │   ├── routes/                # API route handlers
│   │   ├── utils/                 # Utility functions
│   │   ├── __tests__/             # Unit tests
│   │   └── app.ts                 # Main application file
│   ├── Dockerfile                 # Container configuration
│   ├── package.json              # Dependencies and scripts
│   └── jest.config.js            # Test configuration
├── infrastructure/                # Terraform configuration
│   ├── modules/                   # Reusable Terraform modules
│   │   ├── vpc/                   # VPC, subnets, networking
│   │   ├── ec2/                   # EC2 instance configuration
│   │   ├── iam/                   # IAM roles and policies
│   │   ├── ssm/                   # SSM documents and associations
│   │   └── ecr/                   # ECR repository configuration
│   └── environments/
│       └── production/            # Production environment config
│           ├── main.tf            # Main infrastructure file
│           ├── variables.tf       # Input variables
│           ├── outputs.tf         # Output values
│           ├── terraform.tfvars   # Environment-specific values
│           └── scripts/           # Provisioning scripts
└── .github/workflows/             # GitHub Actions CI/CD
    └── deploy.yml                 # Deployment pipeline
```

## 🌐 Access Information

### Application Endpoints
- **Production URL**: `http://<EC2_PUBLIC_IP>:3000`
- **Health Check**: `http://<EC2_PUBLIC_IP>:3000/health`
- **API Documentation**: `http://<EC2_PUBLIC_IP>:3000/api`

### Monitoring
- **CloudWatch Logs**: `/devops-assessment/app` log group
- **CloudWatch Metrics**: `CWAgent` namespace
- **EC2 Instance**: Available via AWS Console

## 🛠️ Local Development

### Prerequisites
- Node.js 20+
- Docker
- AWS CLI
- Terraform

### Setup
```bash
# Clone repository
git clone <repository-url>

# Setup application
cd application
npm install
npm run dev

# Setup infrastructure (optional for local development)
cd ../infrastructure/environments/production
terraform init
```

### Testing
```bash
# Run application tests
cd application
npm test

# Run integration tests
npm run test:integration
```


---

**Note**: This project is designed as a DevOps assessment demonstration and implements enterprise-grade practices while maintaining simplicity for assessment purposes.
