// lib/prisma.ts テンプレート
// Prisma Client の適切な初期化パターン

/*
  prisma-client.ts テンプレート
  テンプレート用のサンプル初期化コードはビルド時の型チェックを壊す
  ため、実際に使用する際はコメントを外して `@prisma/client` を取り込んでください。

import { PrismaClient } from "@prisma/client";

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined;
};

export const prisma = globalForPrisma.prisma ?? ({} as any);

if (process.env.NODE_ENV !== "production") globalForPrisma.prisma = prisma;

*/

// スタブエクスポート（テンプレート）
// eslint-disable-next-line @typescript-eslint/no-explicit-any
export const prisma = {} as any;
