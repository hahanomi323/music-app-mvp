import { Router } from 'express';
import { prisma } from '../db';
import { asyncHandler } from '../utils/asyncHandler';
import { requireAuth, type AuthRequest } from '../middleware/auth';

const router = Router();

router.get(
  '/',
  requireAuth,
  asyncHandler(async (req: AuthRequest, res) => {
    const items = await prisma.listeningHistory.findMany({
      where: { userId: req.userId! },
      orderBy: { listenedAt: 'desc' },
      take: 50,
      include: { song: { include: { artist: true } } }
    });
    return res.json({ items });
  })
);

router.post(
  '/:songId',
  requireAuth,
  asyncHandler(async (req: AuthRequest, res) => {
    const songId = req.params.songId;
    const song = await prisma.song.findUnique({ where: { id: songId } });
    if (!song) return res.status(404).json({ message: 'Không tìm thấy bài hát' });

    await prisma.listeningHistory.create({
      data: { userId: req.userId!, songId }
    });

    return res.json({ ok: true });
  })
);

export default router;

