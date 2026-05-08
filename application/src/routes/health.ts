import { Router, Request, Response } from 'express';
import { logger } from '../utils/logger';

const router = Router();

// Health check endpoint
router.get('/', (req: Request, res: Response) => {
  const healthData = {
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || 'development',
    version: '1.0.0',
    service: 'devops-assessment-app',
    memory: {
      used: Math.round(process.memoryUsage().heapUsed / 1024 / 1024 * 100) / 100,
      total: Math.round(process.memoryUsage().heapTotal / 1024 / 1024 * 100) / 100
    }
  };

  logger.info('Health check accessed', healthData);
  res.status(200).json(healthData);
});

// Detailed health check
router.get('/detailed', (req: Request, res: Response) => {
  const detailedHealth = {
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || 'development',
    version: '1.0.0',
    service: 'devops-assessment-app',
    system: {
      platform: process.platform,
      nodeVersion: process.version,
      pid: process.pid
    },
    memory: process.memoryUsage(),
    cpu: process.cpuUsage()
  };

  logger.info('Detailed health check accessed', detailedHealth);
  res.status(200).json(detailedHealth);
});

export default router;
