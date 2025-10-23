#!/bin/sh

# k6 Test Runner
# Runs all tests in sequence

set -e

MODE=${MODE:-dev}

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
TRAEFIK_URL="http://traefik:8000"
MAX_WAIT=60
WAIT_COUNT=0

while [ $WAIT_COUNT -lt $MAX_WAIT ]; do
  if wget -q -O- "${TRAEFIK_URL}/auth/health" > /dev/null 2>&1; then
    echo "✅ Services are ready!"
    break
  fi
  WAIT_COUNT=$((WAIT_COUNT + 1))
  sleep 1
done

if [ $WAIT_COUNT -eq $MAX_WAIT ]; then
  echo "❌ Services did not become ready in time"
  exit 1
fi

echo ""
echo "========================================="
echo "🧪 Running k6 Tests (${MODE} mode)"
echo "========================================="
echo ""

PASSED=0
FAILED=0
TOTAL=0

run_test() {
  local test_name=$1
  local test_file=$2
  
  TOTAL=$((TOTAL + 1))
  echo ""
  echo "ℹ️  Running: ${test_name}"
  echo "----------------------------------------"
  
  if k6 run -e MODE=${MODE} --quiet "dist/${test_file}.js"; then
    echo "✅ ${test_name} PASSED"
    PASSED=$((PASSED + 1))
  else
    echo "❌ ${test_name} FAILED"
    FAILED=$((FAILED + 1))
  fi
}

echo "========================================="
echo "Phase 1: Auth Service Tests"
echo "========================================="

run_test "Auth - Signup" "auth-signup"
run_test "Auth - Login" "auth-login"
run_test "Auth - Refresh Token" "auth-refresh"
run_test "Auth - Partner Create" "auth-partner"

echo ""
echo "========================================="
echo "Phase 2: User Service Tests"
echo "========================================="

run_test "User - Get Profile" "user-profile"
run_test "User - Update Profile" "user-update"

echo ""
echo "========================================="
echo "Phase 3: Post Service Tests"
echo "========================================="

run_test "Post - Create" "post-create"
run_test "Post - List" "post-list"
run_test "Post - Update" "post-update"
run_test "Post - Delete" "post-delete"

echo ""
echo "========================================="
echo "Phase 4: DUFS Service Tests"
echo "========================================="

run_test "Dufs - Upload" "dufs-upload"
run_test "Dufs - Download" "dufs-download"
run_test "Dufs - Delete" "dufs-delete"

echo ""
echo "========================================="
echo "Phase 5: Integration Flow Tests"
echo "========================================="

run_test "Complete Auth Flow" "flow-auth"
run_test "Complete Post Flow" "flow-post"
run_test "Complete DUFS Flow" "flow-dufs"
run_test "Partner Verification Flow" "flow-partner"

echo ""
echo ""
echo "========================================="
echo "📊 Test Summary"
echo "========================================="
echo ""
echo "Total Tests: ${TOTAL}"
echo "✅ Passed: ${PASSED}"
echo "❌ Failed: ${FAILED}"
echo ""

if [ ${FAILED} -eq 0 ]; then
  echo "========================================="
  echo "✅ ALL TESTS PASSED"
  echo "========================================="
  exit 0
else
  echo "========================================="
  echo "❌ SOME TESTS FAILED"
  echo "========================================="
  exit 1
fi

