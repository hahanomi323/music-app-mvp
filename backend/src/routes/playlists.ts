import { Router } from 'express';
import { z } from 'zod';
import { prisma } from '../db';
import { asyncHandler } from '../utils/asyncHandler';
import { requireAuth, type AuthRequest } from '../middleware/auth';

const router = Router();

router.get(
  '/',
  requireAuth,
  asyncHandler(async (req: AuthRequest, res) => {
    const playlists = await prisma.playlist.findMany({
      where: { userId: req.userId! },
      orderBy: { createdAt: 'desc' },
      include: { _count: { select: { songs: true } } }
    });
    return res.json({ items: playlists });
  })
);

const createSchema = z.object({ name: z.string().min(1).max(60) });

router.post(
  '/',
  requireAuth,
  asyncHandler(async (req: AuthRequest, res) => {
    const data = createSchema.parse(req.body);
    const playlist = await prisma.playlist.create({
      data: { userId: req.userId!, name: data.name }
    });
    return res.status(201).json(playlist);
  })
);

router.get(
  '/:id',
  requireAuth,
  asyncHandler(async (req: AuthRequest, res) => {
    const playlist = await prisma.playlist.findFirst({
      where: { id: req.params.id, userId: req.userId! },
      include: {
        songs: { include: { song: { include: { artist: true } } }, orderBy: { createdAt: 'desc' } }
      }
    });
    if (!playlist) return res.status(404).json({ message: 'Không tìm thấy playlist' });
    return res.json({
      ...playlist,
      songs: playlist.songs.map((x) => x.song)
    });
  })
);

const renameSchema = z.object({ name: z.string().min(1).max(60) });

router.patch(
  '/:id',
  requireAuth,
  asyncHandler(async (req: AuthRequest, res) => {
    const data = renameSchema.parse(req.body);
    const playlist = await prisma.playlist.findFirst({ where: { id: req.params.id, userId: req.userId! } });
    if (!playlist) return res.status(404).json({ message: 'Không tìm thấy playlist' });

    const updated = await prisma.playlist.update({ where: { id: playlist.id }, data: { name: data.name } });
    return res.json(updated);
  })
);

router.delete(
  '/:id',
  requireAuth,
  asyncHandler(async (req: AuthRequest, res) => {
    const playlist = await prisma.playlist.findFirst({ where: { id: req.params.id, userId: req.userId! } });
    if (!playlist) return res.status(404).json({ message: 'Không tìm thấy playlist' });

    await prisma.playlist.delete({ where: { id: playlist.id } });
    return res.json({ ok: true });
  })
);

router.post(
  '/:id/songs/:songId',
  requireAuth,
  asyncHandler(async (req: AuthRequest, res) => {
    const playlist = await prisma.playlist.findFirst({ where: { id: req.params.id, userId: req.userId! } });
    if (!playlist) return res.status(404).json({ message: 'Không tìm thấy playlist' });

    const song = await prisma.song.findUnique({ where: { id: req.params.songId } });
    if (!song) return res.status(404).json({ message: 'Không tìm thấy bài hát' });

    await prisma.playlistSong.upsert({
      where: { playlistId_songId: { playlistId: playlist.id, songId: song.id } },
      create: { playlistId: playlist.id, songId: song.id },
      update: {}
    });

    return res.json({ ok: true });
  })
);

router.delete(
  '/:id/songs/:songId',
  requireAuth,
  asyncHandler(async (req: AuthRequest, res) => {
    const playlist = await prisma.playlist.findFirst({ where: { id: req.params.id, userId: req.userId! } });
    if (!playlist) return res.status(404).json({ message: 'Không tìm thấy playlist' });

    await prisma.playlistSong.deleteMany({
      where: { playlistId: playlist.id, songId: req.params.songId }
    });

    return res.json({ ok: true });
  })
);

export default router;

