import { check } from 'k6';
import http from 'k6/http';
import { config } from '../config';
import { checkResponse, parseJsonResponse, logSuccess, logError, logStep } from '../utils/helpers';

export const options = config.options;

export default function () {
  console.log('\n=========================================');
  console.log('📝 Complete Post Flow Test');
  console.log('=========================================\n');
  
  // Step 1: Login
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
    logError('Login failed');
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
    title: 'Test Post from Flow',
    content: 'This is a test post created during the complete flow test.',
  });
  
  const authParams = {
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${accessToken}`,
    },
  };
  
  const createResponse = http.post(createUrl, createPayload, authParams);
  
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
  
  // Step 3: List posts
  logStep('Step 3: List posts');
  const listUrl = `${config.getKongUrl()}/post/v1/post?page=1&limit=10`;
  
  const listResponse = http.get(listUrl, authParams);
  
  if (!checkResponse(listResponse, 200, 'List Posts')) {
    logError('Failed to list posts');
    return;
  }
  
  const listBody = parseJsonResponse(listResponse);
  const totalPosts = listBody?.data?.meta?.total;
  
  if (totalPosts === undefined) {
    logError('No total posts count received');
    return;
  }
  
  logSuccess(`Found ${totalPosts} posts`);
  
  // Step 4: Update post
  logStep('Step 4: Update post');
  const updateUrl = `${config.getKongUrl()}/post/v1/post/${postId}`;
  
  const updatePayload = JSON.stringify({
    title: 'Updated Test Post',
    content: 'This post has been updated during the flow test.',
  });
  
  const updateResponse = http.put(updateUrl, updatePayload, authParams);
  
  if (!checkResponse(updateResponse, 200, 'Update Post')) {
    logError('Failed to update post');
    return;
  }
  
  logSuccess('Post updated successfully');
  
  // Step 5: Delete post
  logStep('Step 5: Delete post');
  const deleteUrl = `${config.getKongUrl()}/post/v1/post/batch`;
  
  const deletePayload = JSON.stringify({
    ids: [postId],
  });
  
  const deleteResponse = http.del(deleteUrl, deletePayload, authParams);
  
  if (!checkResponse(deleteResponse, 200, 'Delete Post')) {
    logError('Failed to delete post');
    return;
  }
  
  const deleteBody = parseJsonResponse(deleteResponse);
  const deletedCount = deleteBody?.data?.count;
  
  if (!deletedCount) {
    logError('No deleted count received');
    return;
  }
  
  logSuccess('Post deleted successfully');
  
  console.log('\n=========================================');
  console.log('✅ Complete Post Flow Test PASSED');
  console.log('=========================================\n');
}

