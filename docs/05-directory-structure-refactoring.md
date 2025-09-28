# Directory Structure Refactoring Guide

## Overview

このドキュメントは、q-builderプロジェクトにおけるNext.js App Routerルール準拠とfeature-driven architectureの実装過程で実施したディレクトリ構造の変更を記録します。

## App Router Rule Compliance

### 目標

App Routerのベストプラクティス「データ取得やロジックは app/ 直下には書かず、lib/ や features/ に委譲する」の完全準拠

### 実施した変更

#### 1. 認証ロジックの分離

```
app/auth/page.tsx (Server Component) → lib/authGuard.ts へロジック委譲
- requireAuth(): 認証が必要なページでの認証チェック
- redirectIfAuthenticated(): ログイン済みユーザーの適切なリダイレクト
```

#### 2. データベースアクセスの分離

```
app/ でのPrisma直接呼び出し → lib/userCredits.ts へ移動
- getUserCredits(): ユーザークレジット情報の取得
```

#### 3. コンポーネント構造の統一化

```
app/components/ → components/ (共通コンポーネント)
app/auth/components/ → features/auth/_components/
app/workspace/components/ → features/workspace/_components/
```

## Feature-Driven Architecture Implementation

### 基本原則

- 各feature は自己完結したモジュール
- app/ の構造と連動するディレクトリは通常名
- 汎用機能ディレクトリは \_ プレフィックス付き

### Features 構造

#### features/auth/

```
features/auth/
├── _components/     # 認証関連UI コンポーネント
│   ├── AuthCard.tsx
│   ├── DevAuthForms.tsx
│   ├── GoogleSignInButton.tsx
│   └── index.ts
├── _hooks/          # 認証関連カスタムフック
├── _lib/            # 認証ロジック・Server Actions
│   └── actions.ts
├── _schemas/        # バリデーションスキーマ
│   └── authSchemas.ts
├── _types/          # 型定義
└── index.ts         # メインエクスポート
```

#### features/workspace/

```
features/workspace/
├── _components/     # ワークスペース全体コンポーネント
│   ├── ListLink.tsx
│   ├── SidebarContent.tsx
│   ├── WorkspaceClient.tsx
│   └── index.ts
├── _hooks/          # ワークスペース関連フック
├── _lib/            # 共通ロジック・Server Actions
│   ├── actions/
│   └── shared/
├── _providers/      # ワークスペース用Context/Provider
├── _schemas/        # バリデーションスキーマ
├── _types/          # 型定義
├── admin/           # 管理機能 (app/workspace/admin と対応)
├── create/          # 問題作成機能 (app/workspace/create と対応)
│   └── components/
│       └── ImageFormClient.tsx
├── invites/         # 招待機能 (app/workspace/invites と対応)
│   └── _components/
│       ├── InviteDisplay.tsx
│       ├── InviteItem.tsx
│       └── index.ts
├── pages/           # ページ機能 (app/workspace/pages と対応)
│   ├── _components/
│   │   ├── EditResultForm.tsx
│   │   ├── PageList.tsx
│   │   └── index.ts
│   ├── lib/
│   │   └── getPages.ts
│   └── index.ts
└── index.ts
```

### Naming Convention

#### \_ プレフィックス付きディレクトリ

app/ の構造と紐づかない汎用機能:

- `_components/` - UIコンポーネント
- `_hooks/` - カスタムフック
- `_lib/` - ロジック・ユーティリティ
- `_providers/` - Context/Provider
- `_schemas/` - バリデーションスキーマ
- `_types/` - 型定義

#### 通常名ディレクトリ

app/ の構造と対応するサブ機能:

- `admin/` ↔ `app/workspace/admin/`
- `create/` ↔ `app/workspace/create/`
- `invites/` ↔ `app/workspace/invites/`
- `pages/` ↔ `app/workspace/pages/`

## Directory Migration History

### 2025-01-27 実施

#### Phase 1: 基本分離

1. `app/components/` → `components/` (共通コンポーネント)
2. `app/providers/` → `providers/` (グローバルプロバイダー)
3. `app/shared/schemas/` → `schemas/` (共通スキーマ)

#### Phase 2: Feature分離

1. `app/auth/components/` → `features/auth/_components/`
2. `app/auth/schemas/` → `features/auth/_schemas/`
3. `app/auth/types/` → `features/auth/_types/`

#### Phase 3: Workspace構造統一

1. `app/workspace/shared/actions/` → `features/workspace/_lib/actions/`
2. `app/workspace/shared/lib/` → `features/workspace/_lib/shared/`
3. `app/workspace/schemas/` → `features/workspace/_schemas/`
4. `app/workspace/types/` → `features/workspace/_types/`
5. `app/workspace/providers/` → `features/workspace/_providers/`

#### Phase 4: サブディレクトリ構造統一

1. `app/workspace/pages/components/` → `features/workspace/pages/_components/`
2. `features/workspace/_components/pages/` → `features/workspace/pages/_components/`
3. `features/workspace/_components/InviteDisplay.tsx` → `features/workspace/invites/_components/`
4. `features/workspace/_components/InviteItem.tsx` → `features/workspace/invites/_components/`

#### Phase 5: プレフィックス統一

全feature内の汎用ディレクトリに \_ プレフィックスを適用:

- `components/` → `_components/`
- `hooks/` → `_hooks/`
- `lib/` → `_lib/`
- `providers/` → `_providers/`
- `schemas/` → `_schemas/`
- `types/` → `_types/`

## Import Path Updates

### Before

```typescript
import DevAuthForms from "@/app/auth/components/DevAuthForms";
import { clearCookieAction } from "@/app/workspace/shared/actions/authActions";
import PageList from "@/app/workspace/pages/components/PageList";
```

### After

```typescript
import DevAuthForms from "@/features/auth/_components/DevAuthForms";
import { clearCookieAction } from "@/features/workspace/_lib/actions/authActions";
import { PageList } from "@/features/workspace/pages";
```

## Index File Strategy

各ディレクトリにindex.tsを配置してクリーンなエクスポートを実現:

### Feature Level

```typescript
// features/workspace/index.ts
export * from "./_components";
export * from "./_lib/actions";
export * from "./pages/index";
export * from "./invites/index";
```

### Sub-feature Level

```typescript
// features/workspace/pages/index.ts
export * from "./_components";
export * from "./lib/getPages";
```

### Component Level

```typescript
// features/workspace/pages/_components/index.ts
export { default as EditResultForm } from "./EditResultForm";
export { default as PageList } from "./PageList";
```

## Benefits Achieved

### 1. App Router Compliance ✅

- `app/` には純粋なルーティングファイルのみ
- データ取得・ロジックは適切に分離
- Server ComponentsとClient Componentsの明確な分離

### 2. Maintainability ✅

- 機能ごとに関連ファイルが集約
- 依存関係が明確
- コードの場所が予測可能

### 3. Scalability ✅

- 新機能追加時の構造が明確
- 既存機能への影響最小化
- チーム開発での作業分担しやすい

### 4. Developer Experience ✅

- IDE の自動補完・ナビゲーションが向上
- インポートパスが論理的で覚えやすい
- ビルド時間の最適化

## Future Considerations

### 追加予定の機能

- `features/quiz/` - クイズ機能が独立した際
- `features/ai/` - AI機能が拡張された際
- `features/analytics/` - 分析機能追加時

### Migration Rules

新しい機能追加時は以下のルールに従う:

1. app/ の構造と対応するディレクトリは通常名
2. 汎用機能は \_ プレフィックス付き
3. 必ずindex.tsでエクスポートを管理
4. インポートパスは @ を使用した絶対パス

## Troubleshooting

### よくある問題と解決方法

#### Module not found エラー

```bash
# 症状
Module not found: Can't resolve '@/features/workspace/components'

# 解決方法
1. index.ts ファイルの存在確認
2. export文の確認
3. ディレクトリ名の _ プレフィックス確認
```

#### Type declaration エラー

```bash
# 症状
Cannot find module '@/features/auth/types' or its corresponding type declarations

# 解決方法
1. _types/index.ts の存在確認
2. 型エクスポートの確認（export type）
3. tsconfig.json の paths 設定確認
```

#### Circular dependency 警告

```bash
# 症状
Circular dependency detected

# 解決方法
1. インポートの循環参照をチェック
2. index.ts からの再エクスポートを見直し
3. 依存関係の整理
```

## Validation Commands

構造の整合性確認用コマンド:

```bash
# ビルドテスト
npm run build

# 型チェック
npm run typecheck

# リンター実行
npm run lint

# 全テスト実行
npm test
```

---

_Last updated: 2025-01-27_
_Status: ✅ Implementation Complete_
