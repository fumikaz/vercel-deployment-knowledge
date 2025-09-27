# トラブルシューティングガイド

## 🚨 よくある問題と解決法

### 🔥 緊急度高：ビルド・デプロイエラー

#### 1. "Page was prerendered at build time" エラー

**症状**: ビルド時にSSGが実行され、データベース接続エラーが発生

**解決法**:
```typescript
// すべてのAPI Routeに追加
export const dynamic = 'force-dynamic';
export const runtime = 'nodejs';
```

**背景**: Next.jsはデフォルトでページを静的生成しようとするため、ビルド時にデータベースアクセスが実行される

---

#### 2. Prisma Binary Not Found エラー

**症状**: `Query engine binary for current platform "rhel-openssl-3.0.x" could not be found`

**解決法**:
```prisma
// schema.prisma
generator client {
  provider      = "prisma-client-js"
  binaryTargets = ["native", "rhel-openssl-3.0.x"]
}
```

```json
// vercel.json
{
  "env": {
    "PRISMA_CLI_BINARY_TARGET": "rhel-openssl-3.0.x",
    "PRISMA_QUERY_ENGINE_BINARY": "rhel-openssl-3.0.x"
  }
}
```

---

#### 3. Function Timeout エラー

**症状**: `Function execution timed out after 10.00 seconds`

**解決法**:
```json
// vercel.json
{
  "functions": {
    "src/app/api/heavy-task/route.ts": {
      "maxDuration": 300
    },
    "src/app/api/**/*.ts": {
      "maxDuration": 30
    }
  }
}
```

### 🗄️ データベース関連エラー

#### 4. Connection Timeout

**症状**: `connect ETIMEDOUT` または `connection timeout expired`

**解決法**:
```env
# Connection Poolingを使用（推奨）
DATABASE_URL=postgresql://user:pass@host:6543/db?sslmode=require&pgbouncer=true&connect_timeout=60&pool_timeout=60

# 直接接続の場合
DATABASE_URL=postgresql://user:pass@host:5432/db?sslmode=require&connect_timeout=30
```

---

#### 5. Too Many Connections

**症状**: `sorry, too many clients already`

**解決法**:
```typescript
// API Route での適切な接続管理
export async function GET() {
  try {
    const result = await prisma.model.findMany();
    return NextResponse.json(result);
  } finally {
    await prisma.$disconnect(); // 必ず切断
  }
}
```

```env
# Connection Pooling必須
DATABASE_URL=postgresql://user:pass@host:6543/db?sslmode=require&pgbouncer=true
```

---

#### 6. SSL Connection Error

**症状**: `SSL connection required`

**解決法**:
```env
DATABASE_URL=postgresql://user:pass@host:port/db?sslmode=require
```

### 🔐 認証関連エラー

#### 7. Middleware Loop Error

**症状**: ミドルウェアで無限リダイレクトループ

**解決法**:
```typescript
// middleware.ts
export const config = {
  matcher: [
    "/((?!api/auth|_next/static|_next/image|favicon.ico).*)",
  ],
};
```

---

#### 8. Basic Auth Header Missing

**症状**: 401 Unauthorized が頻発

**解決法**:
```typescript
// middleware.ts での適切なチェック
if (basicAuth) {
  const authValue = basicAuth.split(" ")[1];
  if (authValue) {
    const [user, pwd] = atob(authValue).split(":");
    // 認証処理
  }
}
```

### ⚡ パフォーマンス問題

#### 9. Cold Start が遅い

**症状**: 初回アクセス時のレスポンスが遅い

**解決法**:
```typescript
// 軽量な初期化
const prisma = new PrismaClient({
  log: ['error'], // ログレベルを最小限に
});

// 不要な処理を避ける
if (process.env.NODE_ENV !== "production") {
  globalForPrisma.prisma = prisma;
}
```

---

#### 10. API Response が重い

**解決法**:
```typescript
// 必要な項目のみ取得
const users = await prisma.user.findMany({
  select: {
    id: true,
    name: true,
    email: true,
    // 重いフィールドは除外
  },
  take: 50 // 取得件数制限
});
```

## 🔍 デバッグ方法

### Vercel Function Logs の確認

1. Vercel Dashboard → Functions タブ
2. エラーが発生している関数をクリック
3. Logs を確認

### 環境変数の確認

```typescript
// デバッグ用API
export async function GET() {
  return NextResponse.json({
    nodeEnv: process.env.NODE_ENV,
    hasDbUrl: !!process.env.DATABASE_URL,
    // 機密情報は含めない
  });
}
```

### データベース接続テスト

```typescript
// src/app/api/debug-db/route.ts
export const dynamic = 'force-dynamic';

export async function GET() {
  try {
    await prisma.$queryRaw`SELECT 1`;
    return NextResponse.json({ status: 'Connected' });
  } catch (error) {
    return NextResponse.json({ 
      status: 'Error', 
      message: error.message 
    }, { status: 500 });
  }
}
```

## 📋 緊急時チェックリスト

問題が発生した時の確認順序：

1. **[ ] Vercel Function Logs をチェック**
2. **[ ] 環境変数が正しく設定されているか確認**
3. **[ ] API Route に `dynamic = 'force-dynamic'` 設定済みか**
4. **[ ] データベース接続URL の形式が正しいか**
5. **[ ] Prisma binaryTargets 設定済みか**
6. **[ ] 最新のコードがデプロイされているか**

## 🆘 エスカレーション

上記で解決しない場合：

1. [Vercel Community](https://github.com/vercel/vercel/discussions) で検索
2. [Next.js Issues](https://github.com/vercel/next.js/issues) で類似問題を確認
3. Vercel Support に問い合わせ（Pro プラン以上）

## 📚 関連リンク

- [Vercel Function Limits](https://vercel.com/docs/functions/serverless-functions#limits)
- [Prisma Best Practices](https://www.prisma.io/docs/guides/performance-and-optimization)
- [Next.js Deployment Guide](https://nextjs.org/docs/deployment)