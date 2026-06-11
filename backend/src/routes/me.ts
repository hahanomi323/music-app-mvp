import { Router } from 'express';
import { prisma } from '../db';
import { asyncHandler } from '../utils/asyncHandler';
import { requireAuth, type AuthRequest } from '../middleware/auth';

const router = Router();

router.get(
  '/',
  requireAuth,
  asyncHandler(async (req: AuthRequest, res) => {
    const user = await prisma.user.findUnique({
      where: { id: req.userId! },
      select: { id: true, email: true, displayName: true, createdAt: true }
    });
    return res.json(user);
  })
);

export default router;

