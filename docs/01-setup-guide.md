# Vercel 初期セットアップガイド

## 🎯 概要

Next.js アプリケーションをVercelにデプロイするための基本的なセットアップ手順とベストプラクティスです。

## 📋 前提条件

- Next.js プロジェクト（App Router 推奨）
- GitHub リポジトリ
- Vercel アカウント

## 🚀 基本セットアップ

### 1. プロジェクト設定

#### package.json の確認
```json
{
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint"
  }
}
```

#### next.config.ts の設定
```typescript
import type { NextConfig } from 'next';

const nextConfig: NextConfig = {
  eslint: {
    ignoreDuringBuilds: true, // 必要に応じて
  },
  typescript: {
    ignoreBuildErrors: false,
  },
};

export default nextConfig;
```

### 2. API Routes の基本設定

**重要**: すべてのAPI Routeに以下を追加：

```typescript
// 必須設定
export const dynamic = 'force-dynamic';  // SSG無効化
export const runtime = 'nodejs';         // Node.js ランタイム指定

import { NextResponse } from "next/server";

export async function GET() {
  try {
    // メイン処理
    return NextResponse.json({ message: "Success" });
  } catch (error) {
    console.error('API Error:', error);
    return NextResponse.json(
      { error: 'Internal Server Error' }, 
      { status: 500 }
    );
  }
}
```

### 3. vercel.json の作成

プロジェクトルートに `vercel.json` を作成：

```json
{
  "regions": ["iad1"],
  "buildCommand": "npm run build",
  "functions": {
    "src/app/api/**/*.ts": {
      "maxDuration": 30
    }
  }
}
```

### 4. 環境変数の設定

#### .env.local (開発用)
```env
NODE_ENV=development
# その他の開発用変数
```

#### Vercel Dashboard での設定
1. Vercel Dashboard → Settings → Environment Variables
2. 以下を設定：
   ```
   NODE_ENV=production
   ```

## ✅ デプロイ前チェックリスト

- [ ] `dynamic = 'force-dynamic'` がすべてのAPI Routeに設定済み
- [ ] エラーハンドリングがすべてのAPIに実装済み
- [ ] 環境変数がVercel Dashboardに設定済み
- [ ] ビルドが正常に完了する (`npm run build`)
- [ ] TypeScript/ESLintエラーがない

## 🔧 よくある問題と解決法

### ビルドエラー: "Page was prerendered at build time"
```
解決法: export const dynamic = 'force-dynamic'; を追加
```

### API Route がタイムアウト
```
解決法: vercel.json で maxDuration を調整
```

### 環境変数が認識されない
```
解決法: Vercel Dashboard で Environment Variables を確認
```

## 📚 次のステップ

- [データベース設定](./02-database-config.md)
- [API最適化](./03-api-optimization.md)
- [トラブルシューティング](./04-troubleshooting.md)