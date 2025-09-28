# フォーム管理ガイドライン

## 概要

プロジェクト内のすべてのフォームは **React Hook Form + Zod** を使用して構築し、型安全性とバリデーションの一貫性を保つ。

## 技術スタック

- **React Hook Form**: フォーム状態管理とバリデーション
- **Zod**: スキーマバリデーションと型生成
- **@hookform/resolvers/zod**: React Hook FormとZodの連携
- **HeroUI**: UIコンポーネント（プロジェクト標準）

## ディレクトリ構造

各サブディレクトリごとにスキーマとタイプを分離して管理する：

```
app/
├── auth/
│   ├── schemas/
│   │   ├── index.ts          # 全スキーマのエクスポート
│   │   ├── loginSchema.ts     # ログインフォームスキーマ
│   │   └── signupSchema.ts    # サインアップフォームスキーマ
│   ├── types/
│   │   └── index.ts          # Zodから生成された型のエクスポート
│   └── components/
│       └── LoginForm.tsx     # フォームコンポーネント
├── workspace/
│   ├── schemas/
│   │   ├── index.ts
│   │   ├── quizSchema.ts
│   │   └── inviteSchema.ts
│   ├── types/
│   │   └── index.ts
│   └── components/
└── shared/                   # 共通スキーマ
    ├── schemas/
    │   ├── index.ts
    │   └── commonSchema.ts
    └── types/
        └── index.ts
```

## 実装手順

### 1. 必要パッケージのインストール

```bash
npm install react-hook-form zod @hookform/resolvers/zod
npm install -D @types/react-hook-form
```

### 2. Zodスキーマの定義

```typescript
// app/auth/schemas/loginSchema.ts
import { z } from "zod";

export const loginSchema = z.object({
  email: z
    .string()
    .min(1, "メールアドレスは必須です")
    .email("有効なメールアドレスを入力してください"),
  password: z
    .string()
    .min(8, "パスワードは8文字以上で入力してください")
    .regex(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/, "英大文字、小文字、数字を含む必要があります"),
});
```

### 3. TypeScript型の生成

```typescript
// app/auth/types/index.ts
import { z } from "zod";
import { loginSchema } from "../schemas/loginSchema";

export type LoginFormData = z.infer<typeof loginSchema>;
```

### 4. フォームコンポーネントの実装

```typescript
// app/auth/components/LoginForm.tsx
"use client";

import { zodResolver } from '@hookform/resolvers/zod';
import { Button, Input } from '@heroui/react';
import { useForm } from 'react-hook-form';
import { loginSchema } from '../schemas/loginSchema';
import type { LoginFormData } from '../types';

export default function LoginForm() {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
    reset,
  } = useForm<LoginFormData>({
    resolver: zodResolver(loginSchema),
    defaultValues: {
      email: '',
      password: '',
    },
  });

  const onSubmit = async (data: LoginFormData) => {
    try {
      // フォーム送信処理
      console.log('Form data:', data);
    } catch (error) {
      console.error('Submit error:', error);
    }
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
      <Input
        {...register('email')}
        type="email"
        label="メールアドレス"
        placeholder="you@example.com"
        errorMessage={errors.email?.message}
        isInvalid={!!errors.email}
      />

      <Input
        {...register('password')}
        type="password"
        label="パスワード"
        placeholder="********"
        errorMessage={errors.password?.message}
        isInvalid={!!errors.password}
      />

      <Button
        type="submit"
        color="primary"
        isLoading={isSubmitting}
        className="w-full"
      >
        ログイン
      </Button>
    </form>
  );
}
```

## ベストプラクティス

### 1. スキーマ設計

- **明確なエラーメッセージ**: ユーザーにとって分かりやすい日本語メッセージを提供
- **適切なバリデーション**: 必要最小限かつ実用的なバリデーション規則
- **再利用性**: 共通のバリデーション規則は `shared/schemas` に配置

### 2. フォーム状態管理

- **defaultValues**: 常に初期値を設定し、undefined を避ける
- **reset()**: フォーム送信後の適切なリセット処理
- **isSubmitting**: 重複送信防止のための送信状態管理

### 3. エラーハンドリング

- **フィールドレベル**: 各入力フィールドの個別エラー表示
- **フォームレベル**: 送信時の全体的なエラーハンドリング
- **ユーザー体験**: エラー状況の明確な視覚的フィードバック

### 4. HeroUI連携

```typescript
// HeroUIコンポーネントとの適切な連携
<Input
  {...register('fieldName')}
  label="フィールド名"
  errorMessage={errors.fieldName?.message}
  isInvalid={!!errors.fieldName}
  // 他のHeroUI props...
/>
```

## 共通バリデーション規則

```typescript
// app/shared/schemas/commonSchema.ts
import { z } from "zod";

export const commonValidations = {
  email: z
    .string()
    .min(1, "メールアドレスは必須です")
    .email("有効なメールアドレスを入力してください"),

  password: z
    .string()
    .min(8, "パスワードは8文字以上で入力してください")
    .regex(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/, "英大文字、小文字、数字を含む必要があります"),

  requiredString: (fieldName: string) => z.string().min(1, `${fieldName}は必須です`).trim(),

  optionalString: z.string().optional(),

  positiveNumber: z.number().positive("正の数値を入力してください"),
};
```

## 注意事項

### 1. パフォーマンス

- **mode設定**: `mode: 'onBlur'` または `mode: 'onChange'` を適切に選択
- **reValidateMode**: 再バリデーションタイミングの最適化
- **shouldFocusError**: エラー時のフォーカス制御

### 2. アクセシビリティ

- **aria-label**: スクリーンリーダー対応
- **errorMessage**: エラーメッセージの適切な関連付け
- **required属性**: 必須フィールドの明確な表示

### 3. セキュリティ

- **入力サニタイズ**: Zodスキーマでの適切なデータ検証
- **CSRF対策**: フォーム送信時の適切なトークン管理
- **データ漏洩防止**: 機密情報の適切なハンドリング

## チェックリスト

フォーム実装時の確認項目：

- [ ] React Hook Form + Zodの構成で実装されている
- [ ] 適切なディレクトリにスキーマが配置されている
- [ ] TypeScript型がZodから生成されている
- [ ] エラーメッセージが日本語で分かりやすい
- [ ] HeroUIコンポーネントと適切に連携している
- [ ] バリデーション規則が実用的である
- [ ] 送信状態の管理が適切に行われている
- [ ] アクセシビリティが考慮されている

## 移行計画

既存のフォームをReact Hook Form + Zodに移行する際の優先順位：

1. **高頻度使用フォーム**: ログイン、サインアップ
2. **複雑なバリデーション**: クイズ作成、招待管理
3. **シンプルなフォーム**: 設定変更、プロフィール更新

各フォームの移行は段階的に行い、機能テストを十分に実施する。
