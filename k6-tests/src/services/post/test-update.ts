import { check } from 'k6';
import http from 'k6/http';
import { config } from '../../config';
import { checkResponse, parseJsonResponse, logSuccess, logError, logStep } from '../../utils/helpers';

export const options = config.options;

export default function () {
  logStep('Test Update Post');
  
  // Step 1: Login
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
  
  // Step 2: Create a post first
  logStep('Step 2: Create a post');
  const createUrl = `${config.getTraefikUrl()}/post/v1/post`;
  
  const createPayload = JSON.stringify({
    title: 'Test Post for Update',
    content: 'This post will be updated',
  });
  
  const createParams = {
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${accessToken}`,
    },
  };
  
  const createResponse = http.post(createUrl, createPayload, createParams);
  
  if (!checkResponse(createResponse, 201, 'Create Post')) {
    logError('Failed to create post');
    return;
  }
  
  const createBody = parseJsonResponse(createResponse);
  const postId = createBody?.data?.id;
  
  if (!postId) {
    logError('No post ID received');
    return;
  }
  
  logSuccess(`Post created with ID: ${postId}`);
  
  // Step 3: Update the post
  logStep('Step 3: Update the post');
  const updateUrl = `${config.getTraefikUrl()}/post/v1/post/${postId}`;
  
  const updatePayload = JSON.stringify({
    title: 'Updated Test Post',
    content: 'This post has been updated by k6',
  });
  
  const updateParams = {
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${accessToken}`,
    },
  };
  
  const updateResponse = http.put(updateUrl, updatePayload, updateParams);
  
  const success = checkResponse(updateResponse, 200, 'Update Post');
  
  if (success) {
    const body = parseJsonResponse(updateResponse);
    if (body && body.data) {
      logSuccess('Post updated successfully');
    } else {
      logError('Response missing updated post data');
    }
  } else {
    logError(`Update post failed with status ${updateResponse.status}`);
    console.log(updateResponse.body);
  }
}

