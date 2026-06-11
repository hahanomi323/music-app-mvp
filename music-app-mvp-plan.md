# Kế hoạch MVP App Âm Nhạc

## 1. Mục tiêu
Xác định rõ app âm nhạc bản đầu tiên sẽ làm được gì, dành cho ai, và dùng công nghệ nào để triển khai nhanh nhưng vẫn đủ khả năng mở rộng.

## 2. Đối tượng người dùng
### Nhóm người dùng chính
- Người trẻ từ 16-30 tuổi thường nghe nhạc trên điện thoại.
- Người muốn tìm nhanh bài hát và phát nhạc mượt.
- Người thích tự tạo playlist cá nhân.

### Nhu cầu chính
- Đăng ký tài khoản và lưu dữ liệu cá nhân.
- Tìm bài hát nhanh theo tên bài, ca sĩ, album.
- Nghe nhạc ổn định, thao tác đơn giản.
- Lưu bài yêu thích và tạo playlist riêng.
- Xem lại lịch sử nghe để tiếp tục bài hát đã nghe trước đó.

## 3. Tính năng chính
### 3.1 Đăng ký / đăng nhập
- Đăng ký bằng email và mật khẩu.
- Đăng nhập, đăng xuất.
- Quên mật khẩu ở giai đoạn sau nếu cần.

### 3.2 Tìm kiếm bài hát
- Tìm theo tên bài hát.
- Tìm theo tên ca sĩ.
- Tìm theo album hoặc từ khóa liên quan.

### 3.3 Phát nhạc
- Phát / tạm dừng.
- Chuyển bài tiếp / lùi bài.
- Thanh tiến trình bài hát.
- Hiển thị ảnh bìa, tên bài, ca sĩ.

### 3.4 Tạo playlist
- Tạo playlist mới.
- Thêm bài hát vào playlist.
- Xóa bài hát khỏi playlist.
- Đổi tên playlist.

### 3.5 Yêu thích bài hát
- Thả tim bài hát.
- Xem danh sách bài hát yêu thích.

### 3.6 Lịch sử nghe
- Lưu các bài hát đã nghe gần đây.
- Cho phép người dùng mở lại nhanh.

## 4. Phạm vi MVP đề xuất
### Nên làm ngay ở phiên bản đầu
- Đăng ký / đăng nhập.
- Trang chủ danh sách bài hát.
- Tìm kiếm bài hát.
- Trình phát nhạc.
- Tạo playlist cơ bản.
- Yêu thích bài hát.
- Lịch sử nghe.

### Có thể để sau
- Đăng nhập Google / Facebook.
- Gợi ý nhạc theo hành vi.
- Tải nhạc offline.
- Bình luận / chia sẻ bài hát.
- Hệ thống đề xuất nâng cao.

## 5. Wireframe sơ bộ
### 5.1 Màn hình đăng nhập
```text
+----------------------------------+
|           Logo App               |
|                                  |
|   [ Email ]                      |
|   [ Mật khẩu ]                   |
|                                  |
|   [ Đăng nhập ]                  |
|   [ Đăng ký ]                    |
+----------------------------------+
```

### 5.2 Màn hình trang chủ
```text
+----------------------------------+
| Xin chào, User                   |
| [ Ô tìm kiếm bài hát... ]        |
|                                  |
| Danh sách bài hát nổi bật        |
| - Bài hát 1                      |
| - Bài hát 2                      |
| - Bài hát 3                      |
|                                  |
| Bottom Nav: Home | Search | Me   |
+----------------------------------+
```

### 5.3 Màn hình phát nhạc
```text
+----------------------------------+
|          Ảnh bìa                 |
|                                  |
| Tên bài hát                      |
| Tên ca sĩ                        |
|                                  |
| ------- tiến trình -------       |
|                                  |
| [Prev]   [Play/Pause]   [Next]   |
|                                  |
| [Yêu thích] [Thêm playlist]      |
+----------------------------------+
```

### 5.4 Màn hình playlist
```text
+----------------------------------+
| Playlist của tôi                 |
|                                  |
| [ + Tạo playlist mới ]           |
|                                  |
| - Chill buổi tối                 |
| - Nhạc làm việc                  |
| - Nhạc yêu thích                 |
+----------------------------------+
```

### 5.5 Màn hình lịch sử nghe
```text
+----------------------------------+
| Lịch sử nghe                     |
|                                  |
| - Bài hát A                      |
| - Bài hát B                      |
| - Bài hát C                      |
+----------------------------------+
```

## 6. Chọn công nghệ
## Frontend
### Khuyến nghị: Flutter
Lý do:
- UI đẹp và đồng nhất trên mobile.
- Tốc độ phát triển MVP nhanh.
- Phù hợp nếu sau này muốn mở rộng iOS.

### Phương án thay thế: React Native
Phù hợp nếu:
- Team mạnh JavaScript / TypeScript.
- Muốn dùng hệ sinh thái React.

## Backend
### Khuyến nghị: Node.js + Express
Lý do:
- Dễ dựng API nhanh cho MVP.
- Hệ sinh thái lớn.
- Phù hợp với app cần auth, playlist, lịch sử nghe.

## Database
### Khuyến nghị: PostgreSQL
Lý do:
- Dữ liệu có quan hệ rõ: user, bài hát, playlist, lịch sử, yêu thích.
- Query và mở rộng tốt hơn cho bài toán này.

### Phương án thay thế: MongoDB
Phù hợp nếu:
- Muốn schema linh hoạt hơn.
- MVP cần thay đổi cấu trúc dữ liệu liên tục.

## Lưu trữ file nhạc
### Khuyến nghị: Cloudflare R2
Lý do:
- Tối ưu chi phí lưu trữ.
- Phù hợp nếu lưu file audio tĩnh.

### Phương án thay thế: AWS S3
Phù hợp nếu:
- Cần hệ sinh thái AWS đồng bộ.
- Muốn mở rộng hạ tầng lớn hơn sau này.

## 7. Stack đề xuất chốt cho MVP
- Frontend: Flutter
- Backend: Node.js + Express
- Database: PostgreSQL
- Lưu nhạc: Cloudflare R2
- Xác thực: JWT

## 8. Kiến trúc dữ liệu cơ bản
### Bảng / collection chính
- `users`
- `songs`
- `artists`
- `playlists`
- `playlist_songs`
- `favorites`
- `listening_history`

## 9. Luồng người dùng chính
1. Người dùng đăng ký hoặc đăng nhập.
2. Vào trang chủ để xem danh sách bài hát.
3. Tìm kiếm bài hát.
4. Chọn bài để phát.
5. Thêm bài vào yêu thích hoặc playlist.
6. Xem lại trong lịch sử nghe.

## 10. Bước tiếp theo
1. Chốt stack cuối cùng.
2. Thiết kế database schema.
3. Thiết kế API backend.
4. Khởi tạo dự án frontend và backend.
5. Làm màn hình đăng nhập và trang chủ trước.
