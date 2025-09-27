#!/bin/bash

# Vercel ノウハウリポジトリをサブモジュールとして追加するスクリプト
# 使用方法: ./setup-submodule.sh [リポジトリURL]

set -e

REPO_URL="${1:-https://github.com/fumikaz/vercel-deployment-knowledge.git}"
SUBMODULE_PATH="docs/vercel-knowledge"

echo "🚀 Vercel ノウハウリポジトリをサブモジュールとして追加中..."
echo "リポジトリ: $REPO_URL"
echo "パス: $SUBMODULE_PATH"

# サブモジュールを追加
if [ -d "$SUBMODULE_PATH" ]; then
    echo "⚠️  サブモジュールディレクトリが既に存在します: $SUBMODULE_PATH"
    read -p "削除して再追加しますか? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$SUBMODULE_PATH"
        git submodule deinit -f "$SUBMODULE_PATH" 2>/dev/null || true
    else
        echo "❌ 中止しました"
        exit 1
    fi
fi

# サブモジュールを追加
echo "📦 サブモジュールを追加中..."
git submodule add "$REPO_URL" "$SUBMODULE_PATH"

# 初期化と更新
echo "🔄 サブモジュールを初期化中..."
git submodule update --init --recursive

# .gitmodulesファイルを確認
echo "✅ .gitmodulesファイル:"
cat .gitmodules

# コミット
echo "💾 変更をコミット中..."
git add .gitmodules "$SUBMODULE_PATH"
git commit -m "Add Vercel knowledge base as submodule"

echo ""
echo "🎉 セットアップ完了！"
echo ""
echo "📚 使用方法:"
echo "  ノウハウの参照: cat $SUBMODULE_PATH/README.md"
echo "  テンプレート使用: cp $SUBMODULE_PATH/templates/vercel.json ./vercel.json"
echo "  最新版に更新: cd $SUBMODULE_PATH && git pull origin main && cd ../.."
echo ""
echo "🤖 Copilot用ナレッジ:"
echo "  $SUBMODULE_PATH/.copilot/ にCopilot用の構造化されたナレッジがあります"