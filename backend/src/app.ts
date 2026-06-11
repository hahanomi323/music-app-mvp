import express from 'express';
import cors from 'cors';
import path from 'path';

import authRoutes from './routes/auth';
import songsRoutes from './routes/songs';
import playlistsRoutes from './routes/playlists';
import favoritesRoutes from './routes/favorites';
import historyRoutes from './routes/history';
import meRoutes from './routes/me';
import uploadRoutes from './routes/upload';

export function createApp() {
  const app = express();

  app.use(cors());
  app.use(express.json());

  // Serve file nhạc và ảnh bìa tĩnh
  const uploadsDir = path.join(process.cwd(), 'uploads');
  app.use('/uploads', express.static(uploadsDir));

  app.get('/health', (_req, res) => res.json({ ok: true }));

  app.use('/auth', authRoutes);
  app.use('/songs', songsRoutes);
  app.use('/playlists', playlistsRoutes);
  app.use('/favorites', favoritesRoutes);
  app.use('/history', historyRoutes);
  app.use('/me', meRoutes);
  app.use('/upload', uploadRoutes);

  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  app.use((err: any, _req: any, res: any, _next: any) => {
    console.error(err);
    const status = typeof err?.status === 'number' ? err.status : 500;
    res.status(status).json({ message: err?.message || 'Internal Server Error' });
  });

  return app;
}
