import { check } from 'k6';
import http from 'k6/http';
import { config } from '../../config';
import { checkResponse, parseJsonResponse, logSuccess, logError, logStep } from '../../utils/helpers';

export const options = config.options;

export default function () {
  logStep('Test List Posts');
  
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
  
  // Step 2: List posts
  logStep('Step 2: List posts');
  const listUrl = `${config.getKongUrl()}/post/v1/post?page=1&limit=10`;
  
  const listParams = {
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${accessToken}`,
    },
  };
  
  const listResponse = http.get(listUrl, listParams);
  
  const success = checkResponse(listResponse, 200, 'List Posts');
  
  if (success) {
    const body = parseJsonResponse(listResponse);
    if (body && body.data && body.data.meta) {
      logSuccess(`Found ${body.data.meta.total} posts`);
    } else {
      logError('Response missing posts data');
    }
  } else {
    logError(`List posts failed with status ${listResponse.status}`);
    console.log(listResponse.body);
  }
}

