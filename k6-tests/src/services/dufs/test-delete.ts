import { check } from 'k6';
import http from 'k6/http';
import { config } from '../../config';
import { checkResponse, parseJsonResponse, logSuccess, logError, logStep } from '../../utils/helpers';

export const options = config.options;

export default function () {
  logStep('Test File Delete');
  
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
  
  // Step 2: Upload a file first
  logStep('Step 2: Upload a file to delete');
  const timestamp = Date.now();
  const filename = `test-delete-${timestamp}.txt`;
  const uploadUrl = `${config.getTraefikUrl()}/files/${filename}`;
  
  const fileContent = 'This file will be deleted';
  
  const uploadParams = {
    headers: {
      'Content-Type': 'text/plain',
      'Authorization': `Bearer ${accessToken}`,
    },
  };
  
  const uploadResponse = http.put(uploadUrl, fileContent, uploadParams);
  
  if (!check(uploadResponse, { 'Upload: status is 201 or 200': (r) => r.status === 201 || r.status === 200 })) {
    logError('Failed to upload file');
    return;
  }
  
  logSuccess(`File uploaded: ${filename}`);
  
  // Step 3: Delete the file
  logStep('Step 3: Delete the file');
  const deleteUrl = `${config.getTraefikUrl()}/files/${filename}`;
  
  const deleteParams = {
    headers: {
      'Authorization': `Bearer ${accessToken}`,
    },
  };
  
  const deleteResponse = http.del(deleteUrl, null, deleteParams);
  
  const success = check(deleteResponse, {
    'Delete: status is 200 or 204': (r) => r.status === 200 || r.status === 204,
  });
  
  if (success) {
    logSuccess(`File deleted: ${filename}`);
  } else {
    logError(`File delete failed with status ${deleteResponse.status}`);
    console.log(deleteResponse.body);
  }
}

