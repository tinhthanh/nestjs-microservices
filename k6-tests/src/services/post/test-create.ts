import { check } from 'k6';
import http from 'k6/http';
import { config } from '../../config';
import { checkResponse, parseJsonResponse, logSuccess, logError, logStep } from '../../utils/helpers';

export const options = config.options;

export default function () {
  logStep('Test Create Post');
  
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
  
  // Step 2: Create post
  logStep('Step 2: Create post');
  const createUrl = `${config.getKongUrl()}/post/v1/post`;
  
  const createPayload = JSON.stringify({
    title: 'Test Post from k6',
    content: 'This is a test post created by k6 load testing',
  });
  
  const createParams = {
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${accessToken}`,
    },
  };
  
  const createResponse = http.post(createUrl, createPayload, createParams);
  
  const success = checkResponse(createResponse, 201, 'Create Post');
  
  if (success) {
    const body = parseJsonResponse(createResponse);
    if (body && body.data && body.data.id) {
      logSuccess(`Post created with ID: ${body.data.id}`);
    } else {
      logError('Response missing post ID');
    }
  } else {
    logError(`Create post failed with status ${createResponse.status}`);
    console.log(createResponse.body);
  }
}

