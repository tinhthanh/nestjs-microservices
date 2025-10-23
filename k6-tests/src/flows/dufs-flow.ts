import { check } from 'k6';
import http from 'k6/http';
import { config } from '../config';
import { checkResponse, parseJsonResponse, logSuccess, logError, logStep } from '../utils/helpers';

export const options = config.options;

export default function () {
  console.log('\n=========================================');
  console.log('📁 Complete DUFS Flow Test');
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
  
  // Step 2: Upload file
  logStep('Step 2: Upload file');
  const timestamp = Date.now();
  const filename = `test-flow-${timestamp}.txt`;
  const uploadUrl = `${config.getKongUrl()}/files/${filename}`;
  
  const fileContent = `Test file from flow at ${new Date().toISOString()}`;
  
  const uploadParams = {
    headers: {
      'Content-Type': 'text/plain',
      'Authorization': `Bearer ${accessToken}`,
    },
  };
  
  const uploadResponse = http.put(uploadUrl, fileContent, uploadParams);
  
  if (!check(uploadResponse, { 'Upload: status is 201 or 200': (r) => r.status === 201 || r.status === 200 })) {
    logError('File upload failed');
    return;
  }
  
  logSuccess(`File uploaded: ${filename}`);
  
  // Step 3: List files
  logStep('Step 3: List files');
  const listUrl = `${config.getKongUrl()}/files/`;
  
  const listParams = {
    headers: {
      'Authorization': `Bearer ${accessToken}`,
    },
  };
  
  const listResponse = http.get(listUrl, listParams);
  
  if (!check(listResponse, { 'List: status is 200': (r) => r.status === 200 })) {
    logError('File list failed');
    return;
  }
  
  logSuccess('File list retrieved');
  
  // Step 4: Download file
  logStep('Step 4: Download file');
  const downloadUrl = `${config.getKongUrl()}/files/${filename}`;
  
  const downloadResponse = http.get(downloadUrl, listParams);
  
  if (!check(downloadResponse, { 'Download: status is 200': (r) => r.status === 200 })) {
    logError('File download failed');
    return;
  }
  
  logSuccess(`File downloaded: ${filename}`);
  
  // Step 5: Delete file
  logStep('Step 5: Delete file');
  const deleteUrl = `${config.getKongUrl()}/files/${filename}`;
  
  const deleteResponse = http.del(deleteUrl, null, listParams);
  
  if (!check(deleteResponse, { 'Delete: status is 200 or 204': (r) => r.status === 200 || r.status === 204 })) {
    logError('File delete failed');
    return;
  }
  
  logSuccess(`File deleted: ${filename}`);
  
  console.log('\n=========================================');
  console.log('✅ Complete DUFS Flow Test PASSED');
  console.log('=========================================\n');
}

