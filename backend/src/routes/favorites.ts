import { Router } from 'express';
import { prisma } from '../db';
import { asyncHandler } from '../utils/asyncHandler';
import { requireAuth, type AuthRequest } from '../middleware/auth';

const router = Router();

router.get(
  '/',
  requireAuth,
  asyncHandler(async (req: AuthRequest, res) => {
    const items = await prisma.favorite.findMany({
      where: { userId: req.userId! },
      orderBy: { createdAt: 'desc' },
      include: { song: { include: { artist: true } } }
    });

    return res.json({ items: items.map((x) => x.song) });
  })
);

router.post(
  '/:songId',
  requireAuth,
  asyncHandler(async (req: AuthRequest, res) => {
    const songId = req.params.songId;
    const song = await prisma.song.findUnique({ where: { id: songId } });
    if (!song) return res.status(404).json({ message: 'Không tìm thấy bài hát' });

    await prisma.favorite.upsert({
      where: { userId_songId: { userId: req.userId!, songId } },
      create: { userId: req.userId!, songId },
      update: {}
    });
    return res.json({ ok: true });
  })
);

router.delete(
  '/:songId',
  requireAuth,
  asyncHandler(async (req: AuthRequest, res) => {
    const songId = req.params.songId;
    await prisma.favorite.deleteMany({ where: { userId: req.userId!, songId } });
    return res.json({ ok: true });
  })
);

export default router;

