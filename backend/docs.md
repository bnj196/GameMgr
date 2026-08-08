# GameHub Backend

## Cài đặt & chạy

```bash
python -m venv venv
# Windows:
venv\Scripts\activate
# macOS/Linux:
source venv/bin/activate

pip install -r requirements.txt
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

Swagger UI: http://127.0.0.1:8000/docs

## Chạy Flutter client

`API_BASE_URL` là **host của server** (không kèm `/api`, client tự thêm):

```bash
# Máy thật / desktop / web
flutter run --dart-define=USE_MOCK=false --dart-define=API_BASE_URL=http://127.0.0.1:8000

# Android emulator (không thấy 127.0.0.1 của máy host) - cũng là mặc định nếu không truyền
flutter run --dart-define=USE_MOCK=false --dart-define=API_BASE_URL=http://10.0.2.2:8000

# Điện thoại thật cùng mạng LAN
flutter run --dart-define=USE_MOCK=false --dart-define=API_BASE_URL=http://<IP-máy-chạy-server>:8000

# Demo không cần server
flutter run --dart-define=USE_MOCK=true
```

## Hợp đồng API

Mọi endpoint đều nằm dưới prefix `/api`. Response thành công:

```json
{ "success": true, "code": "SUCCESS", "message": "OK", "data": { } }
```

Response lỗi (FastAPI bọc trong `detail`):

```json
{ "detail": { "code": "AUTH_001", "message": "Email hoặc mật khẩu chưa đúng." } }
```

| Method | Path | Auth | Mô tả |
| --- | --- | --- | --- |
| POST | `/api/auth/register` | không | Body `{email, password, username}` → `UserResponse` |
| POST | `/api/auth/login` | không | Body `{email, password}` → `{accessToken, refreshToken}` |
| POST | `/api/auth/refresh` | không | Body `{refreshToken}` → cặp token mới |
| GET | `/api/users/me` | Bearer | Thông tin người dùng hiện tại |
| PATCH | `/api/users/me` | Bearer | Body `{displayName?, avatarUrl?, bio?}` → hồ sơ đã cập nhật |
| POST | `/api/users/me/password` | Bearer | Body `{currentPassword, newPassword}` |
| GET | `/api/games` | Bearer | Xem bảng query bên dưới → `{items, page, limit, total}` |
| GET | `/api/games/facets` | Bearer | Thể loại/nền tảng/kiểu sắp xếp hợp lệ để dựng bộ lọc |
| GET | `/api/games/{id}` | Bearer | Chi tiết game (kèm `ownership`, `rating`) |
| GET | `/api/games/{id}/download-url` | Bearer | Link tải (URL CDN giả lập); 403 nếu chưa sở hữu |
| GET | `/api/games/{id}/reviews` | Bearer | Query `page`, `limit` → `{items, total, summary}` |
| POST | `/api/games/{id}/reviews` | Bearer | Body `{rating 1..5, comment?}`; tạo mới hoặc ghi đè đánh giá của mình |
| DELETE | `/api/games/{id}/reviews/me` | Bearer | Xóa đánh giá của mình |
| GET | `/api/library` | Bearer | Danh sách game trong thư viện |
| POST | `/api/library/{game_id}` | Bearer | Thêm game **miễn phí** vào thư viện (game trả phí → 402) |
| DELETE | `/api/library/{game_id}` | Bearer | Xóa game khỏi thư viện |
| GET | `/api/wishlist` | Bearer | Danh sách game yêu thích |
| POST | `/api/wishlist/{game_id}` | Bearer | Thêm vào yêu thích (409 nếu đã sở hữu) |
| DELETE | `/api/wishlist/{game_id}` | Bearer | Bỏ khỏi yêu thích |
| GET | `/api/orders` | Bearer | Lịch sử đơn hàng, phân trang |
| POST | `/api/orders` | Bearer | Body `{gameId, paymentMethod}` → mua game, tự thêm vào thư viện |
| GET | `/api/orders/{order_id}` | Bearer | Chi tiết đơn hàng |
| GET | `/api/notifications` | Bearer | Query `unreadOnly`, `type`, `page`, `limit` → kèm `unreadCount` |
| GET | `/api/notifications/unread-count` | Bearer | Số thông báo chưa đọc |
| POST | `/api/notifications/{id}/read` | Bearer | Đánh dấu một thông báo đã đọc |
| POST | `/api/notifications/read-all` | Bearer | Đánh dấu tất cả đã đọc |
| DELETE | `/api/notifications/{id}` | Bearer | Xóa thông báo |

### Query của `GET /api/games`

| Tham số | Kiểu | Mô tả |
| --- | --- | --- |
| `q` | string | Tìm theo tên game |
| `genre` | string, lặp lại được | Lọc theo thể loại; nhiều giá trị = AND |
| `platform` | string | `android`, `ios`, ... |
| `priceType` | string | `free` \| `paid` \| `subscription` |
| `minPrice` / `maxPrice` | number | Khoảng giá (game free tính là 0) |
| `sort` | string | `relevance` \| `newest` \| `name_asc` \| `price_asc` \| `price_desc` \| `rating_desc` |
| `page` / `limit` | int | Trang bắt đầu từ 1; `limit` 1..100 |

### Thanh toán

`POST /api/orders` **giả lập** thanh toán và luôn thành công (`paymentMethod`: `momo`, `vnpay`, `card`),
không gọi cổng thanh toán thật. Sau khi mua, game được thêm vào thư viện, xóa khỏi wishlist và
sinh một thông báo loại `order`.

### Token

- `accessToken`: JWT `type=access`, hết hạn sau `ACCESS_TOKEN_EXPIRE_MINUTES` (mặc định 60 phút).
- `refreshToken`: JWT `type=refresh`, hết hạn sau `REFRESH_TOKEN_EXPIRE_MINUTES` (mặc định 30 ngày);
  chỉ dùng được ở `/api/auth/refresh`, không dùng làm access token.
- Client tự gọi `/api/auth/refresh` khi gặp 401 và retry request gốc; nếu refresh thất bại thì
  xóa token và đăng xuất.

### Mã lỗi

| Code | Ý nghĩa |
| --- | --- |
| `AUTH_001` | Sai email hoặc mật khẩu |
| `AUTH_002` | Token hết hạn / không hợp lệ |
| `AUTH_005` | Email đã tồn tại |
| `AUTH_006` | Mật khẩu hiện tại không đúng |
| `AUTH_007` | Mật khẩu mới trùng mật khẩu cũ |
| `GAME_001` | Game không tồn tại |
| `CATALOG_001` / `CATALOG_002` | `priceType` / `sort` không hợp lệ |
| `LIB_001` | Game trả phí, phải mua trước khi thêm vào thư viện |
| `DL_001` | Chưa sở hữu game nên không lấy được link tải |
| `WISH_001` | Game đã có trong thư viện |
| `ORDER_001` | Đã sở hữu game |
| `ORDER_002` | Game miễn phí, không cần mua |
| `ORDER_003` | Phương thức thanh toán không hỗ trợ |
| `ORDER_004` | Không tìm thấy đơn hàng |
| `REVIEW_001` | Chưa sở hữu game nên không đánh giá được |
| `REVIEW_002` | Chưa có đánh giá để xóa |
| `NOTI_001` | Không tìm thấy thông báo |
| `VALIDATION_001` | Dữ liệu gửi lên không hợp lệ (422) |
| `NET_001` / `SRV_001` | Lỗi mạng / lỗi server (do client sinh ra) |

>@cre Tiến Thiện
