# データベース設定ガイド

## 🎯 概要

VercelでのPrisma + Supabase（PostgreSQL）構成を中心としたデータベース設定のベストプラクティスです。

## 🔧 Prisma 設定

### schema.prisma の基本設定

```prisma
generator client {
  provider      = "prisma-client-js"
  binaryTargets = ["native", "rhel-openssl-3.0.x"]  // Vercel用
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

// モデル例
model User {
  id        Int      @id @default(autoincrement())
  email     String   @unique
  name      String?
  createdAt DateTime @default(now()) @map("created_at")
  updatedAt DateTime @updatedAt @map("updated_at")

  @@map("users")
}
```

### PrismaClient の初期化パターン

```typescript
// lib/prisma.ts
import { PrismaClient } from "@prisma/client";

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined;
};

export const prisma = globalForPrisma.prisma ?? new PrismaClient({
  log: process.env.NODE_ENV === "development" ? ["query", "error", "warn"] : ["error"],
});

if (process.env.NODE_ENV !== "production") globalForPrisma.prisma = prisma;
```

## 🐘 Supabase 設定

### 接続URL の設定パターン

#### 推奨: Connection Pooling 使用
```env
DATABASE_URL=postgresql://postgres:password@host:6543/postgres?sslmode=require&pgbouncer=true&connect_timeout=60&pool_timeout=60
```

#### フォールバック: 直接接続
```env
DATABASE_URL=postgresql://postgres:password@host:5432/postgres?sslmode=require&connect_timeout=30
```

### Vercel での環境変数設定例

```
DATABASE_URL=postgresql://postgres:kT3%21gDTEV1kt@db.dfobnrhwtllrkaptdicq.supabase.co:6543/postgres?sslmode=require&pgbouncer=true
```

**注意**: パスワードの特殊文字はURLエンコードが必要
- `!` → `%21`
- `@` → `%40`
- `#` → `%23`

## 🏗️ API での使用パターン

### 基本的なデータベースアクセス

```typescript
// src/app/api/users/route.ts
export const dynamic = 'force-dynamic';
export const runtime = 'nodejs';

import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";

export async function GET() {
  try {
    const users = await prisma.user.findMany({
      orderBy: { createdAt: 'desc' },
      take: 10
    });
    
    return NextResponse.json(users);
  } catch (error) {
    console.error('Database error:', error);
    return NextResponse.json(
      { error: 'Failed to fetch users' }, 
      { status: 500 }
    );
  } finally {
    await prisma.$disconnect();
  }
}

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const { email, name } = body;

    const user = await prisma.user.create({
      data: { email, name }
    });

    return NextResponse.json(user, { status: 201 });
  } catch (error) {
    console.error('Database error:', error);
    return NextResponse.json(
      { error: 'Failed to create user' }, 
      { status: 500 }
    );
  } finally {
    await prisma.$disconnect();
  }
}
```

## ⚡ パフォーマンス最適化

### Connection Pooling の活用

```typescript
// より効率的な接続管理
const prisma = new PrismaClient({
  datasources: {
    db: {
      url: process.env.DATABASE_URL,
    },
  },
  log: ['warn', 'error'],
});

// 接続プールの設定を環境変数で調整
// DATABASE_URL に含める例:
// ?connection_limit=10&pool_timeout=60
```

### インデックスの活用

```prisma
model User {
  id        Int      @id @default(autoincrement())
  email     String   @unique
  status    String
  createdAt DateTime @default(now()) @map("created_at")

  // よく検索される列にインデックス
  @@index([status])
  @@index([createdAt(sort: Desc)])
  
  @@map("users")
}
```

## 🔧 vercel.json でのPrisma設定

```json
{
  "env": {
    "PRISMA_CLI_BINARY_TARGET": "rhel-openssl-3.0.x",
    "PRISMA_QUERY_ENGINE_BINARY": "rhel-openssl-3.0.x"
  },
  "build": {
    "env": {
      "PRISMA_CLI_BINARY_TARGET": "rhel-openssl-3.0.x"
    }
  }
}
```

## 🚨 トラブルシューティング

### よくあるエラーと解決法

#### 1. "Binary targets not found"
```bash
解決法: schema.prisma に binaryTargets = ["native", "rhel-openssl-3.0.x"] を追加
```

#### 2. "Connection timeout"
```bash
解決法: 
- Connection Pooling（6543ポート）を使用
- connect_timeout パラメータを調整
- Supabaseの同時接続数制限を確認
```

#### 3. "SSL connection error"
```bash
解決法: DATABASE_URL に sslmode=require を追加
```

#### 4. "Too many connections"
```bash
解決法:
- pgbouncer=true パラメータを使用
- 不要な接続は必ず $disconnect() で切断
- 接続プールサイズを調整
```

## 📋 デプロイ前チェックリスト

- [ ] schema.prisma に binaryTargets 設定済み
- [ ] DATABASE_URL でConnection Pooling使用
- [ ] 特殊文字がURLエンコード済み
- [ ] API Route で適切にエラーハンドリング実装
- [ ] 接続の切断処理（$disconnect）実装済み
- [ ] 必要なインデックスが設定済み