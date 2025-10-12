#!/bin/bash

# =================================================================
# CHẠY TẤT CẢ API TESTS
# Script này sẽ thực thi tất cả các file test trong thư mục /test-scripts
# =================================================================

echo "========================================="
echo "🚀 Running All API Tests from 'test-scripts/'"
echo "========================================="
echo ""

# Thư mục chứa các test script
TEST_DIR="test-scripts"

# Đảm bảo các script có quyền thực thi
chmod +x $TEST_DIR/*.sh

# Các bước thực thi test
run_test() {
    local test_name=$1
    local script_path=$2
    echo ""
    echo "========================================="
    echo "🧪 $test_name"
    echo "========================================="
    if [ -f "$script_path" ]; then
        "$script_path"
    else
        echo "❌ Lỗi: Không tìm thấy script tại $script_path"
    fi
    sleep 1 # Đợi một chút giữa các lần test
}

run_test "1. Health Check Tests"       "$TEST_DIR/test-health-check.sh"
run_test "2. Signup Test"              "$TEST_DIR/test-signup.sh"
run_test "3. Login Test"               "$TEST_DIR/test-auth-login.sh"
run_test "4. Refresh Token Test"       "$TEST_DIR/test-refresh-token.sh"
run_test "5. Get User Profile Test"    "$TEST_DIR/test-user-profile.sh"
run_test "6. Update User Profile Test" "$TEST_DIR/test-user-update.sh"
run_test "7. Create Post Test"         "$TEST_DIR/test-post-create.sh"
run_test "8. List Posts Test"          "$TEST_DIR/test-post-list.sh"
run_test "9. Update Post Test"         "$TEST_DIR/test-post-update.sh"
run_test "10. Delete Posts Test"       "$TEST_DIR/test-post-delete.sh"

echo ""
echo "========================================="
echo "✅ All API Tests Completed!"
echo "========================================="
