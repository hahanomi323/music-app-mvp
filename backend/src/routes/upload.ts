import { Router } from 'express';
import multer from 'multer';
import path from 'path';
import { z } from 'zod';
import { S3Client, PutObjectCommand, DeleteObjectCommand } from '@aws-sdk/client-s3';
import { prisma } from '../db';
import { asyncHandler } from '../utils/asyncHandler';
import { requireAuth, type AuthRequest } from '../middleware/auth';

const router = Router();

// R2 client
const R2 = new S3Client({
  region: 'auto',
  endpoint: process.env.R2_ENDPOINT,
  credentials: {
    accessKeyId: process.env.R2_ACCESS_KEY_ID!,
    secretAccessKey: process.env.R2_SECRET_ACCESS_KEY!,
  },
});

const BUCKET = process.env.R2_BUCKET_NAME!;
const PUBLIC_URL = process.env.R2_PUBLIC_URL!; // URL public của bucket

// Multer dùng memory storage (không lưu disk)
const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 50 * 1024 * 1024 }, // 50MB
});

const songSchema = z.object({
  title: z.string().min(1).max(100),
  artistName: z.string().min(1).max(100),
  album: z.string().max(100).optional(),
  durationSec: z.coerce.number().int().min(0).optional(),
});

// Upload file lên R2
async function uploadToR2(buffer: Buffer, key: string, contentType: string): Promise<string> {
  await R2.send(new PutObjectCommand({
    Bucket: BUCKET,
    Key: key,
    Body: buffer,
    ContentType: contentType,
  }));
  return `${PUBLIC_URL}/${key}`;
}

// Xóa file khỏi R2
async function deleteFromR2(key: string) {
  try {
    await R2.send(new DeleteObjectCommand({ Bucket: BUCKET, Key: key }));
  } catch (e) {
    console.error('Xóa R2 thất bại:', e);
  }
}

// Lấy key từ URL
function keyFromUrl(url: string): string {
  return url.replace(`${PUBLIC_URL}/`, '');
}

// POST /upload/song
router.post(
  '/song',
  requireAuth,
  upload.fields([{ name: 'audio', maxCount: 1 }, { name: 'cover', maxCount: 1 }]),
  asyncHandler(async (req: AuthRequest, res) => {
    const files = req.files as { [f: string]: Express.Multer.File[] };
    const audioFile = files?.['audio']?.[0];
    if (!audioFile) return res.status(400).json({ message: 'Thiếu file audio' });

    const data = songSchema.parse(req.body);
    const ts = Date.now();
    const rand = Math.random().toString(36).slice(2);

    // Upload audio
    const audioExt = path.extname(audioFile.originalname);
    const audioKey = `audio/${ts}-${rand}${audioExt}`;
    const audioUrl = await uploadToR2(audioFile.buffer, audioKey, audioFile.mimetype || 'audio/mpeg');

    // Upload cover (nếu có)
    let coverUrl: string | null = null;
    const coverFile = files?.['cover']?.[0];
    if (coverFile) {
      const coverExt = path.extname(coverFile.originalname);
      const coverKey = `covers/${ts}-${rand}${coverExt}`;
      coverUrl = await uploadToR2(coverFile.buffer, coverKey, coverFile.mimetype || 'image/jpeg');
    }

    // Tìm hoặc tạo artist
    const artist = await prisma.artist.upsert({
      where: { name: data.artistName },
      update: {},
      create: { name: data.artistName },
    });

    const song = await prisma.song.create({
      data: {
        title: data.title,
        album: data.album,
        durationSec: data.durationSec ?? 0,
        audioUrl,
        coverUrl,
        artistId: artist.id,
      },
      include: { artist: true },
    });

    return res.status(201).json(song);
  })
);

// DELETE /upload/song/:id
router.delete(
  '/song/:id',
  requireAuth,
  asyncHandler(async (req: AuthRequest, res) => {
    const song = await prisma.song.findUnique({ where: { id: req.params.id } });
    if (!song) return res.status(404).json({ message: 'Không tìm thấy bài hát' });

    // Xóa file R2
    await deleteFromR2(keyFromUrl(song.audioUrl));
    if (song.coverUrl) await deleteFromR2(keyFromUrl(song.coverUrl));

    await prisma.song.delete({ where: { id: song.id } });
    return res.json({ ok: true });
  })
);

export default router;
