#!/bin/bash

# Script để kiểm tra toàn bộ luồng xác thực và quản lý file với dufs

# Dừng ngay lập tức nếu có lỗi
set -e

# Load config (URL của Kong)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

echo "========================================="
echo "🚀 Bắt đầu Test luồng DUFS End-to-End"
echo "========================================="
echo ""


# --- BƯỚC 1: Đăng nhập để lấy Access Token ---
echo "--- Bước 1: Đăng nhập vào hệ thống ---"
LOGIN_RESPONSE=$(curl -s -X POST $KONG_URL/auth/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "User123456"
  }')

ACCESS_TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.data.accessToken')

if [ "$ACCESS_TOKEN" == "null" ] || [ -z "$ACCESS_TOKEN" ]; then
  echo "❌ Lỗi: Không lấy được access token. Hãy chắc chắn user 'user@example.com' đã tồn tại."
  echo "Chạy ./test-scripts/test-signup.sh trước."
  exit 1
fi
echo "✅ Lấy Access Token thành công."
echo ""

# --- BƯỚC 2: Thử truy cập DUFS không có Token ---
echo "--- Bước 2: Kiểm tra truy cập không cần xác thực (dự kiến 401) ---"
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/files/)
if [ "$HTTP_STATUS" -eq 401 ]; then
    echo "✅ Thành công: Nhận lỗi 401 Unauthorized đúng như mong đợi."
else
    echo "❌ Thất bại: Mã trạng thái là $HTTP_STATUS thay vì 401."
    exit 1
fi
echo ""

# --- BƯỚC 3: Upload file lên DUFS ---
echo "--- Bước 3: Upload file 'testfile.txt' (dự kiến 201) ---"
# Tạo một file test tạm
echo "Đây là nội dung của file test." > testfile.txt

UPLOAD_STATUS=$(curl -v -s -o /dev/null -w "%{http_code}" -X PUT http://localhost:8000/files/testfile.txt \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -T testfile.txt)

if [ "$UPLOAD_STATUS" -eq 201 ]; then
    echo "✅ Thành công: Upload file thành công với mã trạng thái 201 Created."
else
    echo "❌ Thất bại: Upload file thất bại với mã trạng thái $UPLOAD_STATUS."
    exit 1
fi
echo ""


# --- BƯỚC 4: Tải file về từ DUFS ---
echo "--- Bước 4: Tải file 'testfile.txt' về ---"
DOWNLOADED_CONTENT=$(curl -s http://localhost:8000/files/testfile.txt \
  -H "Authorization: Bearer $ACCESS_TOKEN")

EXPECTED_CONTENT="Đây là nội dung của file test."
if [ "$DOWNLOADED_CONTENT" == "$EXPECTED_CONTENT" ]; then
    echo "✅ Thành công: Nội dung file tải về chính xác."
else
    echo "❌ Thất bại: Nội dung file không khớp."
    echo "   Nội dung mong muốn: '$EXPECTED_CONTENT'"
    echo "   Nội dung nhận được: '$DOWNLOADED_CONTENT'"
    exit 1
fi
echo ""

# --- BƯỚC 5: Xóa file khỏi DUFS ---
echo "--- Bước 5: Xóa file 'testfile.txt' (dự kiến 204) ---"
DELETE_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE http://localhost:8000/files/testfile.txt \
  -H "Authorization: Bearer $ACCESS_TOKEN")

if [ "$DELETE_STATUS" -eq 204 ]; then
    echo "✅ Thành công: Xóa file thành công với mã trạng thái 204 No Content."
else
    echo "❌ Thất bại: Xóa file thất bại với mã trạng thái $DELETE_STATUS."
    exit 1
fi
echo ""

# --- BƯỚC 6: Xác nhận file đã bị xóa ---
echo "--- Bước 6: Kiểm tra lại file đã xóa (dự kiến 404) ---"
VERIFY_DELETE_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/files/testfile.txt \
  -H "Authorization: Bearer $ACCESS_TOKEN")

if [ "$VERIFY_DELETE_STATUS" -eq 404 ]; then
    echo "✅ Thành công: File đã bị xóa và trả về lỗi 404 Not Found."
else
    echo "❌ Thất bại: Vẫn truy cập được file đã xóa với mã trạng thái $VERIFY_DELETE_STATUS."
    exit 1
fi
echo ""


# --- Dọn dẹp ---
rm testfile.txt

echo "========================================="
echo "🎉 TẤT CẢ CÁC BƯỚC KIỂM THỬ DUFS ĐÃ THÀNH CÔNG!"
echo "========================================="