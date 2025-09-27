# Vercel Deployment Knowledge Base (GitHub Copilot 向け)

このファイルはGitHub Copilotが効率的に学習できるよう、Vercelデプロイのパターンとベストプラクティスを構造化したものです。

## 🎯 重要なパターン認識キーワード

`vercel` `next.js` `api-routes` `prisma` `supabase` `deployment` `serverless` `force-dynamic` `binary-targets`

## 📚 基本テンプレート集

### Next.js API Route テンプレート

```typescript
// 必須設定 - すべてのAPI Routeに必要
export const dynamic = 'force-dynamic';  // SSG無効化 - ビルド時DB接続エラー回避
export const runtime = 'nodejs';         // Node.jsランタイム明示

import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";

export async function GET() {
  try {
    const data = await prisma.model.findMany({
      orderBy: { createdAt: 'desc' },
      take: 50  // 取得件数制限でパフォーマンス向上
    });
    return NextResponse.json(data);
  } catch (error) {
    console.error('Database error:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  } finally {
    await prisma.$disconnect(); // 必須: 接続切断
  }
}

export async function POST(request: Request) {
  try {
    const body = await request.json();
    
    // バリデーション
    if (!body.requiredField) {
      return NextResponse.json({ error: 'Missing required field' }, { status: 400 });
    }

    const result = await prisma.model.create({ data: body });
    return NextResponse.json(result, { status: 201 });
  } catch (error) {
    console.error('Create error:', error);
    return NextResponse.json({ error: 'Failed to create' }, { status: 500 });
  } finally {
    await prisma.$disconnect();
  }
}
```

### Prisma設定テンプレート

```prisma
// schema.prisma - Vercel対応設定
generator client {
  provider      = "prisma-client-js"
  binaryTargets = ["native", "rhel-openssl-3.0.x"]  // Vercel必須設定
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

// インデックス設定例
model User {
  id        Int      @id @default(autoincrement())
  email     String   @unique
  status    String
  createdAt DateTime @default(now()) @map("created_at")
  updatedAt DateTime @updatedAt @map("updated_at")

  @@index([status])                    // 検索で使用される列
  @@index([createdAt(sort: Desc)])    // 日付ソート最適化
  @@map("users")
}
```

```typescript
// lib/prisma.ts - シングルトンパターン
import { PrismaClient } from "@prisma/client";

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined;
};

export const prisma = globalForPrisma.prisma ?? new PrismaClient({
  log: process.env.NODE_ENV === "development" ? ["query", "error", "warn"] : ["error"],
});

if (process.env.NODE_ENV !== "production") globalForPrisma.prisma = prisma;
```

### vercel.json 設定テンプレート

```json
{
  "functions": {
    "src/app/api/heavy-task/route.ts": { "maxDuration": 300 },
    "src/app/api/normal/route.ts": { "maxDuration": 60 },
    "src/app/api/**/*.ts": { "maxDuration": 30 }
  },
  "regions": ["iad1"],
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

### 環境変数設定パターン

```env
# 推奨: Connection Pooling使用
DATABASE_URL=postgresql://user:password@host:6543/db?sslmode=require&pgbouncer=true&connect_timeout=60

# 基本設定
NODE_ENV=production

# 認証（オプション）
BASIC_AUTH_USERNAME=admin
BASIC_AUTH_PASSWORD=secure_password
```

### ミドルウェア設定テンプレート

```typescript
// middleware.ts - Basic認証例
import { NextRequest, NextResponse } from "next/server";

export function middleware(request: NextRequest) {
  if (process.env.NODE_ENV === "production") {
    const basicAuth = request.headers.get("authorization");
    
    if (basicAuth) {
      const authValue = basicAuth.split(" ")[1];
      const [user, pwd] = atob(authValue).split(":");
      
      if (user === process.env.BASIC_AUTH_USERNAME && 
          pwd === process.env.BASIC_AUTH_PASSWORD) {
        return NextResponse.next();
      }
    }
    
    const url = request.nextUrl.clone();
    url.pathname = "/api/auth";
    return NextResponse.rewrite(url);
  }
  return NextResponse.next();
}

export const config = {
  matcher: ["/((?!api/auth|_next/static|_next/image|favicon.ico).*)"],
};
```

## 🔧 よくある問題と自動修正パターン

### 問題: "Page was prerendered at build time"
```typescript
// 解決パターン: 以下を追加
export const dynamic = 'force-dynamic';
export const runtime = 'nodejs';
```

### 問題: "Query engine binary not found"
```prisma
// schema.prismaに追加
generator client {
  provider      = "prisma-client-js"
  binaryTargets = ["native", "rhel-openssl-3.0.x"]
}
```

### 問題: "Function timeout"
```json
// vercel.jsonで設定
{
  "functions": {
    "src/app/api/slow-endpoint/route.ts": { "maxDuration": 300 }
  }
}
```

### 問題: "Too many connections"
```typescript
// 解決パターン: 必ずdisconnect
try {
  const result = await prisma.model.findMany();
  return NextResponse.json(result);
} finally {
  await prisma.$disconnect(); // 必須
}
```

## 📋 デプロイチェックリスト

Copilotがコード作成時に確認すべき項目：

- [ ] `export const dynamic = 'force-dynamic'` 設定済み
- [ ] `export const runtime = 'nodejs'` 設定済み
- [ ] エラーハンドリング実装済み
- [ ] `prisma.$disconnect()` 実装済み
- [ ] バリデーション実装済み
- [ ] 適切なHTTPステータスコード設定
- [ ] ログ出力実装済み

## 🎨 コード生成ヒント

Copilotがより良いコードを生成するためのコメントパターン：

```typescript
// Vercel API Route with Prisma and error handling
// Vercel対応のPrisma使用API Route（エラーハンドリング付き）
// Create a secure API endpoint with authentication
// 認証付きセキュアなAPIエンドポイント作成
// Database operation with connection pooling
// Connection Pooling対応のデータベース操作
```

## 🔍 デバッグパターン

```typescript
// デバッグ用APIエンドポイント
export const dynamic = 'force-dynamic';

export async function GET() {
  return NextResponse.json({
    env: process.env.NODE_ENV,
    hasDbUrl: !!process.env.DATABASE_URL,
    timestamp: new Date().toISOString(),
    version: "1.0.0"
  });
}
```

---
**更新**: 2025年9月27日  
**対象**: Next.js 14+, Prisma 5+, Vercel