import { check } from 'k6';
import http from 'k6/http';
import { config } from '../../config';
import { checkResponse, parseJsonResponse, generateTestEmail, logSuccess, logError, logStep } from '../../utils/helpers';

export const options = config.options;

export default function () {
  logStep('Test Signup');
  
  const url = `${config.getKongUrl()}/auth/v1/auth/signup`;
  const email = generateTestEmail();
  
  const payload = JSON.stringify({
    email: email,
    password: config.testUser.password,
    firstName: config.testUser.firstName,
    lastName: config.testUser.lastName,
  });
  
  const params = {
    headers: {
      'Content-Type': 'application/json',
    },
  };
  
  const response = http.post(url, payload, params);
  
  const success = checkResponse(response, 201, 'Signup');
  
  if (success) {
    const body = parseJsonResponse(response);
    if (body && body.data && body.data.accessToken) {
      logSuccess(`User created: ${email}`);
      logSuccess(`Access token received`);
    } else {
      logError('Response missing access token');
    }
  } else {
    logError(`Signup failed with status ${response.status}`);
    console.log(response.body);
  }
}

