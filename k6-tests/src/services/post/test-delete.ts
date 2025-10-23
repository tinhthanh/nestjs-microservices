import { check } from 'k6';
import http from 'k6/http';
import { config } from '../../config';
import { checkResponse, parseJsonResponse, logSuccess, logError, logStep } from '../../utils/helpers';

export const options = config.options;

export default function () {
  logStep('Test Delete Post');
  
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
    title: 'Test Post for Deletion',
    content: 'This post will be deleted',
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
  
  // Step 3: Delete the post
  logStep('Step 3: Delete the post');
  const deleteUrl = `${config.getTraefikUrl()}/post/v1/post/batch`;
  
  const deletePayload = JSON.stringify({
    ids: [postId],
  });
  
  const deleteParams = {
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${accessToken}`,
    },
  };
  
  const deleteResponse = http.del(deleteUrl, deletePayload, deleteParams);
  
  const success = checkResponse(deleteResponse, 200, 'Delete Post');
  
  if (success) {
    const body = parseJsonResponse(deleteResponse);
    if (body && body.data && body.data.count) {
      logSuccess(`Deleted ${body.data.count} post(s)`);
    } else {
      logError('Response missing delete count');
    }
  } else {
    logError(`Delete post failed with status ${deleteResponse.status}`);
    console.log(deleteResponse.body);
  }
}

