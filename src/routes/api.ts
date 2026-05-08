import { Router, Request, Response } from 'express';
import { logger } from '../utils/logger';

const router = Router();

// Main API endpoint - shows DevOps Assessment message
router.get('/', (req: Request, res: Response) => {
  const apiResponse = {
    message: '🎯 DevOps Assessment Test - Production Ready!',
    status: 'success',
    timestamp: new Date().toISOString(),
    version: '1.0.0',
    environment: process.env.NODE_ENV || 'development',
    features: [
      '✅ Node.js + TypeScript',
      '✅ Express.js Framework',
      '✅ Docker Containerization',
      '✅ Terraform Infrastructure',
      '✅ CI/CD Pipeline',
      '✅ AWS CloudWatch Monitoring',
      '✅ Production Best Practices'
    ],
    endpoints: {
      status: '/api/status',
      info: '/api/info',
      metrics: '/api/metrics'
    }
  };

  logger.info('API endpoint accessed', { endpoint: '/api', response: apiResponse });
  res.status(200).json(apiResponse);
});

// Status endpoint
router.get('/status', (req: Request, res: Response) => {
  const status = {
    service: 'devops-assessment-app',
    status: 'operational',
    uptime: process.uptime(),
    timestamp: new Date().toISOString(),
    checks: {
      database: 'not_configured',
      redis: 'not_configured',
      external_apis: 'not_configured'
    }
  };

  logger.info('Status check accessed', status);
  res.status(200).json(status);
});

// Info endpoint
router.get('/info', (req: Request, res: Response) => {
  const info = {
    application: {
      name: 'DevOps Assessment Application',
      description: 'Production-ready Node.js application demonstrating DevOps best practices',
      version: '1.0.0',
      author: 'DevOps Assessment Team',
      repository: 'GitHub Repository'
    },
    technology: {
      backend: 'Node.js + TypeScript',
      framework: 'Express.js',
      containerization: 'Docker',
      infrastructure: 'Terraform + AWS',
      cicd: 'GitHub Actions',
      monitoring: 'AWS CloudWatch'
    },
    deployment: {
      platform: 'AWS EC2',
      instance_type: 't3.micro',
      container_registry: 'Amazon ECR'
    }
  };

  logger.info('Info endpoint accessed', info);
  res.status(200).json(info);
});

// Metrics endpoint
router.get('/metrics', (req: Request, res: Response) => {
  const metrics = {
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    cpu: process.cpuUsage(),
    performance: {
      response_time_ms: Math.random() * 100, // Simulated response time
      requests_per_minute: Math.floor(Math.random() * 50) + 10 // Simulated requests
    }
  };

  logger.info('Metrics endpoint accessed', metrics);
  res.status(200).json(metrics);
});

export default router;
