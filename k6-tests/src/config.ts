// Environment configuration for k6 tests
export const config = {
  // Detect mode from environment variable
  mode: __ENV.MODE || 'dev',
  
  // Base URLs based on mode
  getBaseUrl(): string {
    return this.mode === 'prod'
      ? 'http://traefik:8000'  // In prod, all services behind Traefik
      : 'http://traefik:8000'; // In dev, also use Traefik
  },

  getAuthUrl(): string {
    return this.mode === 'prod'
      ? 'http://traefik:8000/auth'
      : 'http://auth-service:9001'; // Direct access in dev
  },

  getPostUrl(): string {
    return this.mode === 'prod'
      ? 'http://traefik:8000/post'
      : 'http://post-service:9002'; // Direct access in dev
  },

  getTraefikUrl(): string {
    // Keep method name for backward compatibility, but now returns Traefik URL
    return 'http://traefik:8000';
  },
  
  // Test user credentials
  testUser: {
    email: 'user@example.com',
    password: 'User123456',
    firstName: 'Test',
    lastName: 'User',
  },
  
  // k6 options
  options: {
    vus: 1,
    iterations: 1,
    thresholds: {
      http_req_failed: ['rate<0.01'], // http errors should be less than 1%
      http_req_duration: ['p(95)<2000'], // 95% of requests should be below 2s
    },
  },
};

