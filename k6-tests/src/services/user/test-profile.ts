import { check } from 'k6';
import http from 'k6/http';
import { config } from '../../config';
import { checkResponse, parseJsonResponse, logSuccess, logError, logStep } from '../../utils/helpers';

export const options = config.options;

export default function () {
  logStep('Test Get User Profile');
  
  // Step 1: Login to get access token
  logStep('Step 1: Login to get access token');
  const loginUrl = `${config.getKongUrl()}/auth/v1/auth/login`;
  
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
  const accessToken = loginBody?.data?.accessToken;
  
  if (!accessToken) {
    logError('No access token received');
    return;
  }
  
  logSuccess('Access token obtained');
  
  // Step 2: Get user profile
  logStep('Step 2: Get user profile');
  const profileUrl = `${config.getKongUrl()}/auth/v1/user/profile`;
  
  const profileParams = {
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${accessToken}`,
    },
  };
  
  const profileResponse = http.get(profileUrl, profileParams);
  
  const success = checkResponse(profileResponse, 200, 'Get Profile');
  
  if (success) {
    const body = parseJsonResponse(profileResponse);
    if (body && body.data && body.data.email) {
      logSuccess(`Profile retrieved: ${body.data.email}`);
    } else {
      logError('Response missing profile data');
    }
  } else {
    logError(`Get profile failed with status ${profileResponse.status}`);
    console.log(profileResponse.body);
  }
}

