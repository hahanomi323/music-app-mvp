import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
  // Seed artists
  const artist1 = await prisma.artist.upsert({
    where: { name: 'Sơn Tùng M-TP' },
    update: {},
    create: { name: 'Sơn Tùng M-TP', imageUrl: null },
  });
  const artist2 = await prisma.artist.upsert({
    where: { name: 'Hoàng Thùy Linh' },
    update: {},
    create: { name: 'Hoàng Thùy Linh', imageUrl: null },
  });
  const artist3 = await prisma.artist.upsert({
    where: { name: 'Đen Vâu' },
    update: {},
    create: { name: 'Đen Vâu', imageUrl: null },
  });

  // Seed songs (audioUrl là demo public MP3)
  const songs = [
    { title: 'Đừng Làm Trái Tim Anh Đau', album: 'Sky Tour', durationSec: 245, artistId: artist1.id, audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3' },
    { title: 'Lạc Trôi', album: 'Sky Tour', durationSec: 265, artistId: artist1.id, audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3' },
    { title: 'Kẻ Cắp Gặp Bà Già', album: 'HOÀNG', durationSec: 210, artistId: artist2.id, audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3' },
    { title: 'Để Mị Nói Cho Mà Nghe', album: 'HOÀNG', durationSec: 198, artistId: artist2.id, audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3' },
    { title: 'Mang Tiền Về Cho Mẹ', album: 'Single', durationSec: 230, artistId: artist3.id, audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3' },
    { title: 'Bài Này Chill Phết', album: 'Single', durationSec: 215, artistId: artist3.id, audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3' },
  ];

  for (const s of songs) {
    await prisma.song.upsert({
      where: { id: s.title }, // dùng title tạm làm key check
      update: {},
      create: s,
    }).catch(() => prisma.song.create({ data: s }));
  }

  // Seed demo user
  const hash = await bcrypt.hash('123456', 10);
  await prisma.user.upsert({
    where: { email: 'demo@musicapp.dev' },
    update: {},
    create: { email: 'demo@musicapp.dev', displayName: 'Demo User', passwordHash: hash },
  });

  console.log('✅ Seed xong!');
}

main().catch(console.error).finally(() => prisma.$disconnect());
