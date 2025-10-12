# 📚 Documentation Index

## 🎯 Quick Links

### For Quick Testing
- **[Quick Test](./quick-test.sh)** - Chạy test nhanh để kiểm tra services
- **[Test All APIs](./test-all.sh)** - Chạy tất cả API tests
- **[Run All Unit Tests](./run-all-tests.sh)** - Chạy tất cả unit tests

### For Documentation
- **[Testing README](./TESTING_README.md)** - ⭐ START HERE - Quick start guide
- **[Test Summary](./TEST_SUMMARY.md)** - Báo cáo kết quả tests
- **[Testing Guide](./TESTING_GUIDE.md)** - Hướng dẫn chi tiết
- **[Test Scripts README](./TEST_SCRIPTS_README.md)** - Chi tiết về test scripts

---

## 📖 Documentation Structure

### 1. Getting Started
```
TESTING_README.md          ← Start here!
├── Quick Start
├── Test Scripts Overview
├── Usage Instructions
└── Troubleshooting
```

### 2. Test Results
```
TEST_SUMMARY.md
├── Unit Test Results
├── Coverage Analysis
├── Issues & Recommendations
└── Next Steps
```

### 3. Detailed Guides
```
TESTING_GUIDE.md
├── Test Types
├── Running Tests
├── Coverage Details
└── Best Practices

TEST_SCRIPTS_README.md
├── Script Descriptions
├── API Endpoints
├── Usage Examples
└── Troubleshooting
```

---

## 🧪 Test Scripts

### Core Scripts
- `quick-test.sh` - Quick health check + basic API test
- `test-all.sh` - Run all API tests sequentially
- `run-all-tests.sh` - Run all unit tests

### Authentication Tests
- `test-signup.sh` - Test user registration
- `test-auth-login.sh` - Test user login
- `test-refresh-token.sh` - Test token refresh

### User Management Tests
- `test-user-profile.sh` - Test get user profile
- `test-user-update.sh` - Test update user profile

### Post Management Tests
- `test-post-create.sh` - Test create post
- `test-post-list.sh` - Test list posts
- `test-post-update.sh` - Test update post
- `test-post-delete.sh` - Test delete posts

### Health Check Tests
- `test-health-check.sh` - Test all service health endpoints

---

## 🎯 Common Tasks

### I want to...

#### ...quickly check if services are running
```bash
./quick-test.sh
```

#### ...test all API endpoints
```bash
./test-all.sh
```

#### ...run all unit tests
```bash
./run-all-tests.sh
```

#### ...test a specific endpoint
```bash
./test-auth-login.sh
./test-post-create.sh
```

#### ...see test results
```bash
cat TEST_SUMMARY.md
```

#### ...understand how to use test scripts
```bash
cat TEST_SCRIPTS_README.md
```

#### ...learn about testing best practices
```bash
cat TESTING_GUIDE.md
```

---

## 📊 Test Coverage

### Auth Service
- **Tests**: 88 total (80 passed, 8 failed)
- **Coverage**: ~100% statements
- **Status**: ⚠️ Good (needs fixes)

### Post Service
- **Tests**: 101 total (101 passed)
- **Coverage**: ~73% statements
- **Status**: ⚠️ Good (needs improvement)

See [TEST_SUMMARY.md](./TEST_SUMMARY.md) for details.

---

## 🔧 Setup

### Prerequisites
```bash
# Install required tools
brew install curl jq  # macOS
```

### Make scripts executable
```bash
chmod +x *.sh
```

### Start services
```bash
docker-compose up -d
```

---

## 📞 Need Help?

1. **Quick issues**: Check [TESTING_README.md](./TESTING_README.md) → Troubleshooting
2. **Detailed help**: Check [TESTING_GUIDE.md](./TESTING_GUIDE.md) → Troubleshooting
3. **Test script issues**: Check [TEST_SCRIPTS_README.md](./TEST_SCRIPTS_README.md) → Troubleshooting
4. **Service logs**: `docker-compose logs -f`

---

## 🎓 Learning Path

### Beginner
1. Read [TESTING_README.md](./TESTING_README.md)
2. Run `./quick-test.sh`
3. Run `./test-all.sh`

### Intermediate
1. Read [TEST_SCRIPTS_README.md](./TEST_SCRIPTS_README.md)
2. Run individual test scripts
3. Review [TEST_SUMMARY.md](./TEST_SUMMARY.md)

### Advanced
1. Read [TESTING_GUIDE.md](./TESTING_GUIDE.md)
2. Run `./run-all-tests.sh`
3. Contribute to fixing failing tests

---

**Last Updated**: October 12, 2025
