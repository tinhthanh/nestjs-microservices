import { check } from 'k6';
import http from 'k6/http';
import { config } from '../../config';
import { checkResponse, parseJsonResponse, logSuccess, logError, logStep } from '../../utils/helpers';

export const options = config.options;

export default function () {
  logStep('Test File Upload');
  
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
  
  // Step 2: Upload file
  logStep('Step 2: Upload file');
  const timestamp = Date.now();
  const filename = `test-upload-${timestamp}.txt`;
  const uploadUrl = `${config.getKongUrl()}/files/${filename}`;
  
  const fileContent = `Test file uploaded by k6 at ${new Date().toISOString()}`;
  
  const uploadParams = {
    headers: {
      'Content-Type': 'text/plain',
      'Authorization': `Bearer ${accessToken}`,
    },
  };
  
  const uploadResponse = http.put(uploadUrl, fileContent, uploadParams);
  
  const success = check(uploadResponse, {
    'Upload: status is 201 or 200': (r) => r.status === 201 || r.status === 200,
  });
  
  if (success) {
    logSuccess(`File uploaded: ${filename}`);
  } else {
    logError(`File upload failed with status ${uploadResponse.status}`);
    console.log(uploadResponse.body);
  }
}

