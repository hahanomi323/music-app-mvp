import { Router } from 'express';
import { prisma } from '../db';
import { asyncHandler } from '../utils/asyncHandler';

const router = Router();

router.get(
  '/',
  asyncHandler(async (req, res) => {
    const q = String(req.query.q || '').trim();
    const limit = Math.min(Number(req.query.limit || 50), 100);
    const offset = Math.max(Number(req.query.offset || 0), 0);

    const where = q
      ? {
          OR: [
            { title: { contains: q, mode: 'insensitive' as const } },
            { album: { contains: q, mode: 'insensitive' as const } },
            { artist: { name: { contains: q, mode: 'insensitive' as const } } }
          ]
        }
      : {};

    const songs = await prisma.song.findMany({
      where,
      orderBy: { createdAt: 'desc' },
      take: limit,
      skip: offset,
      include: { artist: true }
    });

    return res.json({ items: songs });
  })
);

router.get(
  '/:id',
  asyncHandler(async (req, res) => {
    const song = await prisma.song.findUnique({
      where: { id: req.params.id },
      include: { artist: true }
    });
    if (!song) return res.status(404).json({ message: 'Không tìm thấy bài hát' });
    return res.json(song);
  })
);

export default router;

