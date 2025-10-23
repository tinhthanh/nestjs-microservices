import { check } from 'k6';
import http from 'k6/http';
import { config } from '../../config';
import { checkResponse, parseJsonResponse, logSuccess, logError, logStep } from '../../utils/helpers';

export const options = config.options;

export default function () {
  logStep('Test Update User Profile');
  
  // Step 1: Login to get access token
  logStep('Step 1: Login to get access token');
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
  const accessToken = loginBody?.data?.accessToken;
  
  if (!accessToken) {
    logError('No access token received');
    return;
  }
  
  logSuccess('Access token obtained');
  
  // Step 2: Update user profile
  logStep('Step 2: Update user profile');
  const updateUrl = `${config.getTraefikUrl()}/auth/v1/user/profile`;
  
  const updatePayload = JSON.stringify({
    firstName: 'Updated',
    lastName: 'Name',
  });
  
  const updateParams = {
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${accessToken}`,
    },
  };
  
  const updateResponse = http.put(updateUrl, updatePayload, updateParams);
  
  const success = checkResponse(updateResponse, 200, 'Update Profile');
  
  if (success) {
    const body = parseJsonResponse(updateResponse);
    if (body && body.data) {
      logSuccess('Profile updated successfully');
    } else {
      logError('Response missing updated profile data');
    }
  } else {
    logError(`Update profile failed with status ${updateResponse.status}`);
    console.log(updateResponse.body);
  }
}

