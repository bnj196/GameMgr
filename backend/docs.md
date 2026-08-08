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
| GET | `/api/games` | Bearer | Query `q`, `page` (>=1), `limit` (1..100) → `{items, page, limit, total}` |
| GET | `/api/games/{id}` | Bearer | Chi tiết game (kèm `ownership.owned`) |
| GET | `/api/games/{id}/download-url` | Bearer | Link tải (hiện là URL CDN giả lập) |
| GET | `/api/library` | Bearer | Danh sách game trong thư viện |
| POST | `/api/library/{game_id}` | Bearer | Thêm game vào thư viện |
| DELETE | `/api/library/{game_id}` | Bearer | Xóa game khỏi thư viện |

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
| `GAME_001` | Game không tồn tại |
| `VALIDATION_001` | Dữ liệu gửi lên không hợp lệ (422) |
| `NET_001` / `SRV_001` | Lỗi mạng / lỗi server (do client sinh ra) |

>@cre Tiến Thiện
