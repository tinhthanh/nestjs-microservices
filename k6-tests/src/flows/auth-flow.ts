import { check } from 'k6';
import http from 'k6/http';
import { config } from '../config';
import { checkResponse, parseJsonResponse, generateTestEmail, logSuccess, logError, logStep } from '../utils/helpers';

export const options = config.options;

export default function () {
  console.log('\n=========================================');
  console.log('🔑 Complete Auth Flow Test');
  console.log('=========================================\n');
  
  // Step 1: Signup
  logStep('Step 1: User signup');
  const signupUrl = `${config.getTraefikUrl()}/auth/v1/auth/signup`;
  const email = generateTestEmail();
  
  const signupPayload = JSON.stringify({
    email: email,
    password: config.testUser.password,
    firstName: config.testUser.firstName,
    lastName: config.testUser.lastName,
  });
  
  const params = {
    headers: {
      'Content-Type': 'application/json',
    },
  };
  
  const signupResponse = http.post(signupUrl, signupPayload, params);
  
  if (!checkResponse(signupResponse, 201, 'Signup')) {
    logError('Signup failed');
    return;
  }
  
  const signupBody = parseJsonResponse(signupResponse);
  const accessToken = signupBody?.data?.accessToken;
  
  if (!accessToken) {
    logError('No access token from signup');
    return;
  }
  
  logSuccess(`User created: ${email}`);
  
  // Step 2: Verify access token by getting profile
  logStep('Step 2: Verify access token');
  const profileUrl = `${config.getTraefikUrl()}/auth/v1/user/profile`;
  
  const profileParams = {
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${accessToken}`,
    },
  };
  
  const profileResponse = http.get(profileUrl, profileParams);
  
  if (!checkResponse(profileResponse, 200, 'Get Profile')) {
    logError('Failed to verify access token');
    return;
  }
  
  logSuccess('Access token is valid');
  
  // Step 3: Login with the new user
  logStep('Step 3: Login with new user');
  const loginUrl = `${config.getTraefikUrl()}/auth/v1/auth/login`;
  
  const loginPayload = JSON.stringify({
    email: email,
    password: config.testUser.password,
  });
  
  const loginResponse = http.post(loginUrl, loginPayload, params);
  
  if (!checkResponse(loginResponse, 201, 'Login')) {
    logError('Login failed');
    return;
  }
  
  const loginBody = parseJsonResponse(loginResponse);
  const refreshToken = loginBody?.data?.refreshToken;
  
  if (!refreshToken) {
    logError('No refresh token from login');
    return;
  }
  
  logSuccess('Login successful');
  
  // Step 4: Refresh token
  logStep('Step 4: Refresh access token');
  const refreshUrl = `${config.getTraefikUrl()}/auth/v1/auth/refresh`;
  
  const refreshParams = {
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${refreshToken}`,
    },
  };
  
  const refreshResponse = http.get(refreshUrl, refreshParams);
  
  if (!checkResponse(refreshResponse, 200, 'Refresh Token')) {
    logError('Token refresh failed');
    return;
  }
  
  const refreshBody = parseJsonResponse(refreshResponse);
  const newAccessToken = refreshBody?.data?.accessToken;
  
  if (!newAccessToken) {
    logError('No new access token from refresh');
    return;
  }
  
  logSuccess('Token refresh successful');
  
  // Step 5: Verify new access token
  logStep('Step 5: Verify new access token');
  const verifyParams = {
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${newAccessToken}`,
    },
  };
  
  const verifyResponse = http.get(profileUrl, verifyParams);
  
  if (!checkResponse(verifyResponse, 200, 'Verify New Token')) {
    logError('New access token is invalid');
    return;
  }
  
  logSuccess('New access token is valid');
  
  console.log('\n=========================================');
  console.log('✅ Complete Auth Flow Test PASSED');
  console.log('=========================================\n');
}

