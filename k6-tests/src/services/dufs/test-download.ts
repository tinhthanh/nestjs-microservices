import { check } from 'k6';
import http from 'k6/http';
import { config } from '../../config';
import { checkResponse, parseJsonResponse, logSuccess, logError, logStep } from '../../utils/helpers';

export const options = config.options;

export default function () {
  logStep('Test File Download');
  
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
  
  // Step 2: List files
  logStep('Step 2: List available files');
  const listUrl = `${config.getKongUrl()}/files/`;
  
  const listParams = {
    headers: {
      'Authorization': `Bearer ${accessToken}`,
    },
  };
  
  const listResponse = http.get(listUrl, listParams);
  
  const success = check(listResponse, {
    'List: status is 200': (r) => r.status === 200,
  });
  
  if (success) {
    logSuccess('File list retrieved');
  } else {
    logError(`File list failed with status ${listResponse.status}`);
    console.log(listResponse.body);
  }
}

