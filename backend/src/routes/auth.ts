import { Router } from 'express';
import { z } from 'zod';
import { prisma } from '../db';
import { asyncHandler } from '../utils/asyncHandler';
import { hashPassword, verifyPassword } from '../utils/password';
import { signToken } from '../utils/jwt';

const router = Router();

const registerSchema = z.object({
  email: z.string().email(),
  password: z.string().min(6),
  displayName: z.string().min(1).max(50)
});

router.post(
  '/register',
  asyncHandler(async (req, res) => {
    const data = registerSchema.parse(req.body);

    const existing = await prisma.user.findUnique({ where: { email: data.email } });
    if (existing) return res.status(409).json({ message: 'Email đã tồn tại' });

    const passwordHash = await hashPassword(data.password);
    const user = await prisma.user.create({
      data: { email: data.email, displayName: data.displayName, passwordHash },
      select: { id: true, email: true, displayName: true, createdAt: true }
    });

    const token = signToken({ userId: user.id });
    return res.json({ token, user });
  })
);

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(1)
});

router.post(
  '/login',
  asyncHandler(async (req, res) => {
    const data = loginSchema.parse(req.body);
    const user = await prisma.user.findUnique({ where: { email: data.email } });
    if (!user) return res.status(401).json({ message: 'Sai email hoặc mật khẩu' });

    const ok = await verifyPassword(data.password, user.passwordHash);
    if (!ok) return res.status(401).json({ message: 'Sai email hoặc mật khẩu' });

    const token = signToken({ userId: user.id });
    return res.json({
      token,
      user: { id: user.id, email: user.email, displayName: user.displayName, createdAt: user.createdAt }
    });
  })
);

export default router;

