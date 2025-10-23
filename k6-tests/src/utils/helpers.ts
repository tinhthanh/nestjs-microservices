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

