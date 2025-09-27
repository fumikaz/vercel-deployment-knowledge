# Vercel Deployment Knowledge Base

このリポジトリは、Vercelでのデプロイに関するノウハウを蓄積・共有するためのナレッジベースです。

## 🎯 目的

- Vercelデプロイのベストプラクティスを一元管理
- 複数プロジェクト間でのノウハウ共有
- GitHub Copilotに学習させるための構造化されたナレッジ提供

## 📁 構成

```
vercel-deployment-knowledge/
├── README.md                    # このファイル
├── docs/                        # 詳細ドキュメント
│   ├── 01-setup-guide.md       # 初期セットアップガイド
│   ├── 02-database-config.md   # データベース設定
│   ├── 03-api-optimization.md  # API最適化
│   └── 04-troubleshooting.md   # トラブルシューティング
├── templates/                   # 再利用可能テンプレート
│   ├── vercel.json             # Vercel設定テンプレート
│   ├── middleware.ts           # ミドルウェアテンプレート
│   ├── api-route-template.ts   # API Routeテンプレート
│   └── env-template.txt        # 環境変数テンプレート
├── scripts/                     # 自動化スクリプト
│   ├── setup-submodule.sh     # サブモジュール設定スクリプト
│   └── deploy-check.sh        # デプロイ前チェックスクリプト
├── examples/                    # 実装例
│   └── next-prisma-supabase/  # Next.js + Prisma + Supabase例
└── .copilot/                    # GitHub Copilot専用ナレッジ
    ├── knowledge-base.md       # 構造化されたパターン集
    └── patterns.md             # よく使うコードパターン
```

## 🚀 使用方法

### サブモジュールとして追加

```bash
# プロジェクトルートで実行
git submodule add https://github.com/fumikaz/vercel-deployment-knowledge.git docs/vercel-knowledge
git submodule update --init --recursive
```

### ノウハウの参照

```bash
# 最新のノウハウを取得
cd docs/vercel-knowledge
git pull origin main
cd ../..
```

### テンプレート使用

```bash
# テンプレートファイルをプロジェクトにコピー
cp docs/vercel-knowledge/templates/vercel.json ./vercel.json
cp docs/vercel-knowledge/templates/middleware.ts ./src/middleware.ts
```

## 📋 クイックチェックリスト

Vercelデプロイ前の確認項目：

- [ ] API Routeに `export const dynamic = 'force-dynamic'` 設定済み
- [ ] Prismaのbinary targetが設定済み (`rhel-openssl-3.0.x`)
- [ ] データベース接続でConnection Pooling使用
- [ ] 環境変数がVercelダッシュボードに設定済み
- [ ] vercel.jsonでタイムアウト設定済み
- [ ] 認証設定（必要に応じて）

## 🔄 更新方法

このナレッジベースに新しいノウハウを追加する場合：

1. 該当するドキュメントを更新
2. 新しいテンプレートがあれば `templates/` に追加
3. Copilot用ナレッジ（`.copilot/`）も更新
4. 各プロジェクトでサブモジュール更新を実行

## 🤝 貢献

新しいノウハウや改善提案があれば、以下の方法で貢献してください：

1. Issues で提案
2. Pull Request で直接改善
3. 実際のプロジェクトでの使用経験をフィードバック

---

**更新日**: 2025年9月27日  
**バージョン**: 1.0.0