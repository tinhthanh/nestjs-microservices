import { check } from 'k6';
import http from 'k6/http';

export function checkResponse(response: any, expectedStatus: number, testName: string): boolean {
  const checks = {
    [`${testName}: status is ${expectedStatus}`]: (r: any) => r.status === expectedStatus,
    [`${testName}: response has body`]: (r: any) => r.body !== null && r.body !== '',
  };

  return check(response, checks);
}

export function parseJsonResponse(response: any): any {
  try {
    return JSON.parse(response.body as string);
  } catch (e) {
    // @ts-ignore - k6 console
    console.error(`Failed to parse JSON response: ${e}`);
    return null;
  }
}

export function generateTestEmail(): string {
  const timestamp = Date.now();
  return `testuser${timestamp}@example.com`;
}

export function logSuccess(message: string): void {
  // @ts-ignore - k6 console
  console.log(`✅ ${message}`);
}

export function logError(message: string): void {
  // @ts-ignore - k6 console
  console.error(`❌ ${message}`);
}

export function logInfo(message: string): void {
  // @ts-ignore - k6 console
  console.log(`ℹ️  ${message}`);
}

export function logStep(step: string): void {
  // @ts-ignore - k6 console
  console.log(`\n--- ${step} ---`);
}

/**
 * Ensure a test user exists by attempting to create it
 * If user already exists (409), that's fine - we'll use it
 * Returns true if user exists (either created or already existed)
 */
export function ensureTestUser(baseUrl: string, email: string, password: string, firstName: string, lastName: string): boolean {
  const url = `${baseUrl}/auth/v1/auth/signup`;

  const payload = JSON.stringify({
    email,
    password,
    firstName,
    lastName,
  });

  const params = {
    headers: {
      'Content-Type': 'application/json',
    },
  };

  const response = http.post(url, payload, params);

  // 201 = created, 409 = already exists (both are OK)
  if (response.status === 201) {
    logInfo(`Test user created: ${email}`);
    return true;
  } else if (response.status === 409) {
    logInfo(`Test user already exists: ${email}`);
    return true;
  } else {
    logError(`Failed to ensure test user exists: ${response.status}`);
    console.log(response.body);
    return false;
  }
}

/**
 * Login and get access token
 * Returns the access token or null if login failed
 */
export function loginAndGetToken(baseUrl: string, email: string, password: string): string | null {
  const url = `${baseUrl}/auth/v1/auth/login`;

  const payload = JSON.stringify({
    email,
    password,
  });

  const params = {
    headers: {
      'Content-Type': 'application/json',
    },
  };

  const response = http.post(url, payload, params);

  if (response.status === 201) {
    const body = parseJsonResponse(response);
    if (body && body.data && body.data.accessToken) {
      return body.data.accessToken;
    }
  }

  logError(`Login failed with status ${response.status}`);
  console.log(response.body);
  return null;
}

