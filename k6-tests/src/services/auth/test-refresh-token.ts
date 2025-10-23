import { check } from 'k6';
import http from 'k6/http';
import { config } from '../../config';
import { checkResponse, parseJsonResponse, logSuccess, logError, logStep } from '../../utils/helpers';

export const options = config.options;

export default function () {
  logStep('Test Refresh Token');
  
  // Step 1: Login to get refresh token
  logStep('Step 1: Login to get refresh token');
  const loginUrl = `${config.getTraefikUrl()}/auth/v1/auth/login`;
  
  const loginPayload = JSON.stringify({
    email: config.testUser.email,
    password: config.testUser.password,
  });
  
  const params = {
    headers: {
      'Content-Type': 'application/json',
    },
  };
  
  const loginResponse = http.post(loginUrl, loginPayload, params);
  
  if (!checkResponse(loginResponse, 201, 'Login')) {
    logError('Failed to login');
    return;
  }
  
  const loginBody = parseJsonResponse(loginResponse);
  const refreshToken = loginBody?.data?.refreshToken;
  
  if (!refreshToken) {
    logError('No refresh token received from login');
    return;
  }
  
  logSuccess('Refresh token obtained');
  
  // Step 2: Use refresh token to get new access token
  logStep('Step 2: Use refresh token to get new access token');
  const refreshUrl = `${config.getTraefikUrl()}/auth/v1/auth/refresh`;
  
  const refreshParams = {
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${refreshToken}`,
    },
  };
  
  const refreshResponse = http.get(refreshUrl, refreshParams);
  
  const success = checkResponse(refreshResponse, 200, 'Refresh Token');
  
  if (success) {
    const body = parseJsonResponse(refreshResponse);
    if (body && body.data && body.data.accessToken) {
      logSuccess('Token refresh successful');
      logSuccess('New access token received');
    } else {
      logError('Response missing new access token');
    }
  } else {
    logError(`Token refresh failed with status ${refreshResponse.status}`);
    console.log(refreshResponse.body);
  }
}

