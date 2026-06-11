/*
  Warnings:

  - The primary key for the `Favorite` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - A unique constraint covering the columns `[userId,songId]` on the table `Favorite` will be added. If there are existing duplicate values, this will fail.
  - Made the column `durationSec` on table `Song` required. This step will fail if there are existing NULL values in that column.

*/
-- DropForeignKey
ALTER TABLE "Playlist" DROP CONSTRAINT "Playlist_userId_fkey";

-- DropIndex
DROP INDEX "Favorite_songId_idx";

-- DropIndex
DROP INDEX "ListeningHistory_songId_idx";

-- DropIndex
DROP INDEX "ListeningHistory_userId_listenedAt_idx";

-- DropIndex
DROP INDEX "Playlist_userId_idx";

-- DropIndex
DROP INDEX "PlaylistSong_songId_idx";

-- DropIndex
DROP INDEX "Song_artistId_idx";

-- DropIndex
DROP INDEX "Song_title_idx";

-- AlterTable
ALTER TABLE "Artist" ADD COLUMN     "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN     "imageUrl" TEXT;

-- AlterTable
ALTER TABLE "Favorite" DROP CONSTRAINT "Favorite_pkey";

-- AlterTable
ALTER TABLE "Song" ALTER COLUMN "durationSec" SET NOT NULL;

-- CreateIndex
CREATE UNIQUE INDEX "Favorite_userId_songId_key" ON "Favorite"("userId", "songId");

-- AddForeignKey
ALTER TABLE "Playlist" ADD CONSTRAINT "Playlist_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
