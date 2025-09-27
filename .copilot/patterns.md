# Vercel Code Patterns (Copilot Quick Reference)

GitHub Copilotが素早く適切なコードを生成するためのパターン集です。

## 🚀 Quick Patterns

### 基本API Route
```typescript
// Vercel API Route template
export const dynamic = 'force-dynamic';
export const runtime = 'nodejs';

import { NextResponse } from "next/server";

export async function GET() {
  try {
    // 処理
    return NextResponse.json({ success: true });
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
```

### データベースアクセス
```typescript
// Database access with Prisma
export const dynamic = 'force-dynamic';

import { prisma } from "@/lib/prisma";

export async function GET() {
  try {
    const users = await prisma.user.findMany();
    return NextResponse.json(users);
  } finally {
    await prisma.$disconnect();
  }
}
```

### 認証付きAPI
```typescript
// Authenticated API Route
export const dynamic = 'force-dynamic';

import { headers } from 'next/headers';

export async function GET() {
  const headersList = headers();
  const auth = headersList.get('authorization');
  
  if (!auth) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }
  
  // 処理続行
}
```

### Cron Job API
```typescript
// Vercel Cron API
export const dynamic = 'force-dynamic';

export async function GET() {
  const authHeader = headers().get('authorization');
  if (authHeader !== `Bearer ${process.env.CRON_SECRET}`) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }
  
  // Cron処理
}
```

### エラーハンドリング
```typescript
// Comprehensive error handling
try {
  const result = await operation();
  return NextResponse.json(result);
} catch (error) {
  console.error('Operation failed:', error);
  
  if (error.code === 'P2002') { // Prisma unique constraint
    return NextResponse.json({ error: 'Duplicate entry' }, { status: 409 });
  }
  
  return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
}
```

## 🗄️ Database Patterns

### 基本CRUD操作
```typescript
// Create
const user = await prisma.user.create({
  data: { email, name }
});

// Read
const users = await prisma.user.findMany({
  where: { status: 'active' },
  orderBy: { createdAt: 'desc' },
  take: 10
});

// Update
const updated = await prisma.user.update({
  where: { id },
  data: { name }
});

// Delete
await prisma.user.delete({
  where: { id }
});
```

### リレーション操作
```typescript
// Include relations
const userWithPosts = await prisma.user.findUnique({
  where: { id },
  include: {
    posts: {
      orderBy: { createdAt: 'desc' },
      take: 5
    }
  }
});

// Select specific fields
const users = await prisma.user.findMany({
  select: {
    id: true,
    email: true,
    name: true
  }
});
```

## 🔐 Authentication Patterns

### JWT認証
```typescript
// JWT verification
import jwt from 'jsonwebtoken';

const token = headers().get('authorization')?.replace('Bearer ', '');
if (!token) {
  return NextResponse.json({ error: 'No token' }, { status: 401 });
}

try {
  const payload = jwt.verify(token, process.env.JWT_SECRET!);
  // 認証成功
} catch {
  return NextResponse.json({ error: 'Invalid token' }, { status: 401 });
}
```

### Basic認証
```typescript
// Basic Auth
const authHeader = headers().get('authorization');
if (!authHeader?.startsWith('Basic ')) {
  return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
}

const credentials = atob(authHeader.split(' ')[1]);
const [username, password] = credentials.split(':');

if (username !== process.env.USERNAME || password !== process.env.PASSWORD) {
  return NextResponse.json({ error: 'Invalid credentials' }, { status: 401 });
}
```

## 📊 Data Validation

### Zod バリデーション
```typescript
// Validation with Zod
import { z } from 'zod';

const schema = z.object({
  email: z.string().email(),
  name: z.string().min(1),
  age: z.number().min(0).optional()
});

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const validated = schema.parse(body);
    
    // 処理続行
  } catch (error) {
    return NextResponse.json({ error: 'Validation failed' }, { status: 400 });
  }
}
```

### 手動バリデーション
```typescript
// Manual validation
const { email, name } = await request.json();

if (!email || !email.includes('@')) {
  return NextResponse.json({ error: 'Invalid email' }, { status: 400 });
}

if (!name || name.length < 1) {
  return NextResponse.json({ error: 'Name is required' }, { status: 400 });
}
```

## 📈 Performance Patterns

### ページネーション
```typescript
// Cursor-based pagination
const { cursor, limit = 10 } = await request.json();

const posts = await prisma.post.findMany({
  take: limit + 1,
  cursor: cursor ? { id: cursor } : undefined,
  orderBy: { id: 'desc' }
});

const hasMore = posts.length > limit;
const items = hasMore ? posts.slice(0, -1) : posts;

return NextResponse.json({
  items,
  hasMore,
  nextCursor: hasMore ? items[items.length - 1].id : null
});
```

### キャッシュ制御
```typescript
// Cache control headers
return new NextResponse(JSON.stringify(data), {
  headers: {
    'Content-Type': 'application/json',
    'Cache-Control': 'public, s-maxage=3600, stale-while-revalidate=86400'
  }
});
```

## 🔍 Debugging Patterns

### ログ出力
```typescript
// Structured logging
console.log('API Request:', {
  method: request.method,
  url: request.url,
  timestamp: new Date().toISOString(),
  userAgent: headers().get('user-agent')
});

console.error('Database Error:', {
  error: error.message,
  code: error.code,
  operation: 'user.create',
  timestamp: new Date().toISOString()
});
```

### デバッグエンドポイント
```typescript
// Debug endpoint
export const dynamic = 'force-dynamic';

export async function GET() {
  return NextResponse.json({
    timestamp: new Date().toISOString(),
    nodeEnv: process.env.NODE_ENV,
    hasDbUrl: !!process.env.DATABASE_URL,
    vercelRegion: process.env.VERCEL_REGION,
    functionName: process.env.VERCEL_FUNCTION_NAME
  });
}
```

## 🚀 Common Response Patterns

### 成功レスポンス
```typescript
// Success responses
return NextResponse.json({ success: true, data: result });
return NextResponse.json(result, { status: 201 }); // Created
return NextResponse.json({ message: 'Updated successfully' });
```

### エラーレスポンス
```typescript
// Error responses
return NextResponse.json({ error: 'Not found' }, { status: 404 });
return NextResponse.json({ error: 'Validation failed', details: errors }, { status: 400 });
return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
return NextResponse.json({ error: 'Forbidden' }, { status: 403 });
return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
```

---
**使い方**: コメントでパターン名を書くとCopilotが適切なコードを生成
例: `// Vercel API Route with Prisma database access`