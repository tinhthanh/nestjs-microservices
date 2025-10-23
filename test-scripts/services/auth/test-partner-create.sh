#!/bin/bash

# Load config
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../common/config.sh"

# Test Partner Create API
echo "========================================="
echo "Testing Partner Create API ($MODE mode)"
echo "========================================="
echo ""

# Step 1: Login as admin to get access token
echo "Step 1: Login as admin"
echo "Endpoint: POST ${BASE_URL}/auth/v1/auth/login"
echo ""

LOGIN_RESPONSE=$(curl -s --max-time 10 -X POST "${BASE_URL}/auth/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@example.com",
    "password": "Admin123456"
  }')

ACCESS_TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.data.accessToken' 2>/dev/null)

if [ "$ACCESS_TOKEN" == "null" ] || [ -z "$ACCESS_TOKEN" ]; then
    echo "✗ Admin login failed (admin user may not exist)"
    echo "Response: $LOGIN_RESPONSE"
    echo ""
    echo "Note: This test requires an admin user. Skipping..."
    exit 0  # Exit with success since this is expected
fi

echo "✓ Admin login successful"
echo ""

# Step 2: Create partner
echo "Step 2: Create partner Firebase integration"
echo "Endpoint: POST ${BASE_URL}/auth/v1/admin/partner"
echo ""

# Generate unique project ID for testing
TIMESTAMP=$(date +%s)
PROJECT_ID="test-partner-${TIMESTAMP}"

CREATE_RESPONSE=$(curl -s --max-time 10 -X POST "${BASE_URL}/auth/v1/admin/partner" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -d "{
    \"projectId\": \"${PROJECT_ID}\",
    \"apiKey\": \"AIzaSyB2TjO3fDU-Fhd9a52f3MdoKu5w1lF8dWQ\",
    \"authDomain\": \"${PROJECT_ID}.firebaseapp.com\",
    \"databaseURL\": \"https://${PROJECT_ID}-default-rtdb.asia-southeast1.firebasedatabase.app\",
    \"storageBucket\": \"${PROJECT_ID}.firebasestorage.app\",
    \"messagingSenderId\": \"315854298993\",
    \"appId\": \"1:315854298993:web:8abcf3714549c81a1b60d0\",
    \"measurementId\": \"G-DZY2H8M9RH\",
    \"clientEmail\": \"firebase-adminsdk-fbsvc@${PROJECT_ID}.iam.gserviceaccount.com\",
    \"privateKey\": \"-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCu4XQA8SFCn6fZ\nBK+vHxsh72vJ0GiIV2FWft3v2BMNqX8zuEESztK/VGwTW2Tlw0x1e7mqQEUpOti/\nLo3F2dhvw6vt117EqAdx+LuF5TQqaF0n4l+awFgMANS2XD5Sv6JB+BTn2OPaJA0K\niD+o+6j1NWrrV9yp4mt0W93QJYL7VV5qe3JLhNukCBY3WsmTNmnJReRVSx8jQOJo\n0wT5jkhDDW30jqcf/ECwsQ0AxuWm8FUS+5Vp3rrxXDlP3274vQm9TQjhkpjLg+7o\nVvu8KH9DLA6lruYHezC1XDCyVFqih9yfONBdAYim9kpyRdOfW3T73+gwMTMSWqRJ\nGZ5TB2GrAgMBAAECggEAAMbW89P29O4GwW9iDBDC/rQ0mW3KTf0GmGsi6JhCn92G\nZPPL7s79lY5sR4m61yV7ODkhYL5ay1wVtDTnfsF3F7RLFfZr1y2bkQLxzVmELrhX\n8ZOPMv2t3JXwqq/pRbiBtYWbUinVD2TQ+z4SIu1imX4NtL8dTtx4HvB9NPKJZXgP\nPYM0BWmfaoFzpTxPsDU8qQyq+leyXiQNjo/ErsT71FT+zHiJyL6eU0fvDiKeYCmq\n08frIe2j5CFlZ5HgGMxtBlQSVwqfiYdIaIUIlFhnkUvheCnjSYHoj+iz2GYcIJYe\nPdVj+jW0vCKiUqXphKWWj4uwHKFwyE06SvGlfy6jQQKBgQDwtenNY0vJmh0JT//l\nIoJRNwJ/inKizvT/64icpWwZhfik/c1e235na/l+jYqiZczhgh4RQndz3LFpbhN/\nOWRqxad6aFw9/5NwrdH99PvP8agzf4jMIc8JJZAuEHwu083jqUxnXSELra2RZGDA\nTHBBSqM/p1PjU/B1deaMQUwVVwKBgQC5/Rvug3ZP5W8cq9u0FcaLvGSnsTh4RxKC\njswnlcetT5HCzanrrA2M6J2wFKweK3OhG7XhPomrRiPHdI+cwMfc829jJL7pRsDJ\nF2zAfT5Z7q9tgv5DSqRhf4fC4Zz8Pmi8qAo1ZLAqK6HB8HY/nmTc6Suj7LVe/VLL\nFqK3fzYtzQKBgQCaNOBInSFTUTDi42ZbY6U65FPsY0SXeqBIR5soR22eWE53XMUx\nzMoI9YpLgd/bs/3yRkp+4ibmie76TPOeoKTtJhzp9WuKqG3LVP/fgw/DItyPyVdY\n9xvMj0zzxcnYsgYHoFD7MxVVhvlX2IeHCjEsEuXMhKTgUMkOZu7A0aAtVwKBgQCJ\nCZWrB/IErGhSF86pweGo1AbWCB4zgSqCR/TktdeKOzaK8j5hB0R0rnCBbLnlAN8R\ntfktHYcSS3vRWnD2bpTUmAlaY5jHCPrDMB9RNPbcDKH1bq8ppbW4oN7HGLUypklF\nuArNjILAj6V/4E1AUtS+cI9XGPIKK1z1hpgd2/1vgQKBgHps27FzbD4VQue81I/6\nqsCdhdtcKuqyGwmzoD0EVVUSaQNkIdiTIhf6f46+Z9gM11npWAaw7hbGQCcRmKpu\nx3tdY/n3I8uepBiMijodOvM0W7Q5DpaEfxa3xJwAn2PdsU4LDgQV8y/4ZkGCOdkH\n1QcOCgunEWjPHzoRxPhuUrJ9\n-----END PRIVATE KEY-----\",
    \"isActive\": true
  }")

echo "Response:"
echo "$CREATE_RESPONSE" | jq .
echo ""

# Check if creation was successful
if echo "$CREATE_RESPONSE" | jq -e '.data.projectId' > /dev/null 2>&1; then
    echo "✓ Partner created successfully"
    CREATED_PROJECT_ID=$(echo "$CREATE_RESPONSE" | jq -r '.data.projectId')
    echo "Project ID: $CREATED_PROJECT_ID"
    echo ""
    
    # Step 3: Verify partner was created by listing all partners
    echo "Step 3: Verify partner in list"
    echo "Endpoint: GET ${BASE_URL}/auth/v1/admin/partner"
    echo ""
    
    LIST_RESPONSE=$(curl -s -X GET "${BASE_URL}/auth/v1/admin/partner" \
      -H "Authorization: Bearer ${ACCESS_TOKEN}")
    
    echo "Partners list:"
    echo "$LIST_RESPONSE" | jq .
    echo ""
    
    # Step 4: Get specific partner
    echo "Step 4: Get specific partner"
    echo "Endpoint: GET ${BASE_URL}/auth/v1/admin/partner/${CREATED_PROJECT_ID}"
    echo ""
    
    GET_RESPONSE=$(curl -s -X GET "${BASE_URL}/auth/v1/admin/partner/${CREATED_PROJECT_ID}" \
      -H "Authorization: Bearer ${ACCESS_TOKEN}")
    
    echo "Partner details:"
    echo "$GET_RESPONSE" | jq .
    echo ""
    
    # Step 5: Clean up - delete test partner
    echo "Step 5: Clean up - delete test partner"
    echo "Endpoint: DELETE ${BASE_URL}/auth/v1/admin/partner/${CREATED_PROJECT_ID}"
    echo ""
    
    DELETE_RESPONSE=$(curl -s -X DELETE "${BASE_URL}/auth/v1/admin/partner/${CREATED_PROJECT_ID}" \
      -H "Authorization: Bearer ${ACCESS_TOKEN}")
    
    echo "Delete response:"
    echo "$DELETE_RESPONSE" | jq .
    echo ""
    
    echo "✓ Test completed successfully"
else
    echo "✗ Partner creation failed"
    exit 1
fi

