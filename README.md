# Music App MVP

Stack: **Node.js + Express + Prisma + PostgreSQL** (backend) · **Flutter** (mobile)

---

## Cấu trúc thư mục

```
music-app-mvp/
├── backend/
│   ├── prisma/
│   │   ├── schema.prisma     ← định nghĩa database
│   │   └── seed.ts           ← dữ liệu mẫu
│   ├── src/
│   │   ├── middleware/auth.ts
│   │   ├── routes/           ← auth, songs, playlists, favorites, history, me
│   │   ├── utils/            ← jwt, password, asyncHandler
│   │   ├── app.ts
│   │   ├── db.ts
│   │   └── index.ts
│   ├── docker-compose.yml
│   ├── .env
│   └── package.json
└── mobile/
    └── lib/
        ├── models/           ← song, playlist, user
        ├── services/         ← api_client, auth_service, music_service
        ├── state/            ← auth_state, player_state
        ├── screens/          ← login, register, home, player, playlists, me
        ├── config.dart
        └── main.dart
```

---

## Chạy Backend

### Bước 1 – Khởi động PostgreSQL
```bash
cd backend
docker-compose up -d
```

### Bước 2 – Cài dependencies
```bash
npm install
```

### Bước 3 – Generate Prisma client & migrate database
```bash
npx prisma migrate dev --name init
```

### Bước 4 – Seed dữ liệu mẫu
```bash
npm run db:seed
```

### Bước 5 – Chạy server
```bash
npm run dev
# API chạy tại http://localhost:4000
```

**Tài khoản demo:** `demo@musicapp.dev` / `123456`

---

## Chạy Flutter

```bash
cd mobile
flutter create .        # sinh thêm android/, ios/, ...
flutter pub get
flutter run
```

> **Lưu ý:** Backend phải đang chạy trước khi mở app Flutter.
> - Android emulator → tự động dùng `10.0.2.2:4000`  
> - iOS simulator / desktop → dùng `localhost:4000`

---

## API Endpoints

| Method | Path | Auth | Mô tả |
|--------|------|------|-------|
| POST | /auth/register | ✗ | Đăng ký |
| POST | /auth/login | ✗ | Đăng nhập |
| GET | /me | ✓ | Thông tin user |
| GET | /songs?q=... | ✗ | Danh sách / tìm kiếm |
| GET | /songs/:id | ✗ | Chi tiết bài hát |
| GET | /favorites | ✓ | Bài yêu thích |
| POST | /favorites/:songId | ✓ | Thêm yêu thích |
| DELETE | /favorites/:songId | ✓ | Xóa yêu thích |
| GET | /playlists | ✓ | Danh sách playlist |
| POST | /playlists | ✓ | Tạo playlist |
| GET | /playlists/:id | ✓ | Chi tiết playlist |
| PATCH | /playlists/:id | ✓ | Đổi tên |
| DELETE | /playlists/:id | ✓ | Xóa playlist |
| POST | /playlists/:id/songs/:songId | ✓ | Thêm bài vào playlist |
| DELETE | /playlists/:id/songs/:songId | ✓ | Xóa bài khỏi playlist |
| GET | /history | ✓ | Lịch sử nghe |
| POST | /history/:songId | ✓ | Ghi lịch sử |

---

## Bước tiếp theo (sau MVP)

- [ ] Upload nhạc thật (S3 / Cloudflare R2)
- [ ] Upload ảnh bìa
- [ ] Phân trang (cursor-based)
- [ ] Push notification
- [ ] Deploy lên Railway / Fly.io
