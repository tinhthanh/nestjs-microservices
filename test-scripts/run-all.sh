#!/bin/bash

# Master script to run all tests

# Load config
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHOW_MODE=true source "$SCRIPT_DIR/common/config.sh"
source "$SCRIPT_DIR/common/utils.sh"

print_header "🚀 Running All Tests ($MODE mode)"

TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Function to run a test script
run_test_script() {
    local test_name=$1
    local test_script=$2
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    echo ""
    print_info "Running: $test_name"
    echo "----------------------------------------"
    
    # Chạy script trong subshell để không thay đổi thư mục làm việc hiện tại
    (bash "$SCRIPT_DIR/$test_script") > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        print_success "$test_name PASSED"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        return 0
    else
        print_error "$test_name FAILED"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

# ============================================
# PHASE 1: Database Seeding (MỚI)
# ============================================
print_header "Phase 1: Database Seeding"
print_info "Seeding Firebase config for partner 'vetgo-ai-01'..."
# Lấy đường dẫn thư mục gốc của dự án
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Sử dụng lệnh seed phù hợp với môi trường
SEED_COMMAND="npm run prisma:seed"
if [ "$MODE" = "dev" ]; then
    SEED_COMMAND="npm run prisma:seed:dev" # <--- THAY ĐỔI Ở ĐÂY
fi

(cd "$PROJECT_ROOT/auth" && $SEED_COMMAND)
if [ $? -eq 0 ]; then
    print_success "Database seeded successfully"
else
    print_error "Database seeding failed. Aborting tests."
    exit 1
fi


# ============================================
# PHASE 2: Health Checks
# ============================================
print_header "Phase 2: Health Checks skip"


# ============================================
# PHASE 3: Service Tests
# ============================================
print_header "Phase 3: Service Tests"

# Auth Service Tests
echo ""
print_step "Auth Service Tests"
run_test_script "Auth - Signup" "services/auth/test-signup.sh"
run_test_script "Auth - Login" "services/auth/test-login.sh"
run_test_script "Auth - Refresh Token" "services/auth/test-refresh-token.sh"
run_test_script "Auth - Partner Create" "services/auth/test-partner-create.sh"

# User Service Tests
echo ""
print_step "User Service Tests"
run_test_script "User - Get Profile" "services/user/test-profile-get.sh"
run_test_script "User - Update Profile" "services/user/test-profile-update.sh"

# Post Service Tests
echo ""
print_step "Post Service Tests"
run_test_script "Post - Create" "services/post/test-create.sh"
run_test_script "Post - List" "services/post/test-list.sh"
run_test_script "Post - Update" "services/post/test-update.sh"
run_test_script "Post - Delete" "services/post/test-delete.sh"

# Dufs Service Tests
echo ""
print_step "Dufs Service Tests"
run_test_script "Dufs - Upload" "services/dufs/test-upload.sh"
run_test_script "Dufs - Download" "services/dufs/test-download.sh"
run_test_script "Dufs - Delete" "services/dufs/test-delete.sh"

# ============================================
# PHASE 4: Integration Flow Tests
# ============================================
print_header "Phase 4: Integration Flow Tests"
run_test_script "Complete Auth Flow" "flows/auth-flow.sh"
run_test_script "Complete Post Flow" "flows/post-flow.sh"
run_test_script "Complete DUFS Flow" "flows/dufs-flow.sh"
run_test_script "Partner Verification Flow" "flows/partner-verify-flow.sh"

# ============================================
# Summary
# ============================================
echo ""
echo ""
print_header "📊 Test Summary"
echo ""
echo "Total Tests: $TOTAL_TESTS"
print_success "Passed: $PASSED_TESTS"
print_error "Failed: $FAILED_TESTS"
echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    print_header "✅ ALL TESTS PASSED"
    exit 0
else
    print_header "❌ SOME TESTS FAILED"
    exit 1
fi