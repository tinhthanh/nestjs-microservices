import { check } from 'k6';
import http from 'k6/http';
import { config } from '../../config';
import { checkResponse, parseJsonResponse, logSuccess, logError, logStep } from '../../utils/helpers';

export const options = config.options;

export default function () {
  logStep('Test Login');
  
  const url = `${config.getKongUrl()}/auth/v1/auth/login`;
  
  const payload = JSON.stringify({
    email: config.testUser.email,
    password: config.testUser.password,
  });
  
  const params = {
    headers: {
      'Content-Type': 'application/json',
    },
  };
  
  const response = http.post(url, payload, params);
  
  const success = checkResponse(response, 201, 'Login');
  
  if (success) {
    const body = parseJsonResponse(response);
    if (body && body.data && body.data.accessToken && body.data.refreshToken) {
      logSuccess('Login successful');
      logSuccess('Access token and refresh token received');
    } else {
      logError('Response missing tokens');
    }
  } else {
    logError(`Login failed with status ${response.status}`);
    console.log(response.body);
  }
}

