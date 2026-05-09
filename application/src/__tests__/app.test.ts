import request from 'supertest';
import express from 'express';
import { createApp } from '../app';

describe('Application Tests', () => {
  let app: express.Application;

  beforeAll(() => {
    app = createApp();
  });

  describe('Health Endpoint', () => {
    it('should return health status', async () => {
      const response = await request(app)
        .get('/health')
        .expect(200);

      expect(response.body).toHaveProperty('status', 'healthy');
      expect(response.body).toHaveProperty('timestamp');
      expect(response.body).toHaveProperty('uptime');
    });
  });

  describe('API Endpoint', () => {
    it('should return API message', async () => {
      const response = await request(app)
        .get('/api')
        .expect(200);

      expect(response.body).toHaveProperty('message');
      expect(response.body).toHaveProperty('status', 'success');
      expect(response.body).toHaveProperty('features');
      expect(Array.isArray(response.body.features)).toBe(true);
    });
  });

  describe('Build Process', () => {
    it('should have all required modules', () => {
      expect(() => require('../app')).not.toThrow();
    });
  });
});
