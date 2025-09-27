#!/bin/bash

# Vercel デプロイ前チェックスクリプト
# プロジェクトがVercelデプロイ準備完了かを確認

set -e

echo "🔍 Vercel デプロイ前チェックを開始..."
echo ""

ERRORS=0
WARNINGS=0

# カラーコード
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

error() {
    echo -e "${RED}❌ $1${NC}"
    ((ERRORS++))
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    ((WARNINGS++))
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# 1. 基本ファイルの存在確認
echo "📋 基本ファイル確認..."

if [ -f "package.json" ]; then
    success "package.json が存在"
else
    error "package.json が見つかりません"
fi

if [ -f "next.config.ts" ] || [ -f "next.config.js" ] || [ -f "next.config.mjs" ]; then
    success "Next.js設定ファイルが存在"
else
    warning "next.config.* が見つかりません"
fi

if [ -f "vercel.json" ]; then
    success "vercel.json が存在"
    
    # vercel.jsonの内容をチェック
    if grep -q "rhel-openssl-3.0.x" vercel.json; then
        success "Prisma binary target設定済み"
    elif [ -f "prisma/schema.prisma" ]; then
        warning "Prismaを使用しているようですが、vercel.jsonにbinary target設定がありません"
    fi
else
    warning "vercel.json が見つかりません"
fi

# 2. API Routes確認
echo ""
echo "🔌 API Routes確認..."

if [ -d "src/app/api" ]; then
    API_FILES=$(find src/app/api -name "route.ts" -o -name "route.js" 2>/dev/null || echo "")
    if [ -n "$API_FILES" ]; then
        success "API Routeファイルが見つかりました"
        
        # force-dynamic設定をチェック
        MISSING_DYNAMIC=()
        while IFS= read -r file; do
            if [ -n "$file" ]; then
                if ! grep -q "export const dynamic.*force-dynamic" "$file"; then
                    MISSING_DYNAMIC+=("$file")
                fi
            fi
        done <<< "$API_FILES"
        
        if [ ${#MISSING_DYNAMIC[@]} -eq 0 ]; then
            success "すべてのAPI Routeに dynamic = 'force-dynamic' 設定済み"
        else
            error "以下のAPI Routeに 'export const dynamic = \"force-dynamic\"' が不足:"
            for file in "${MISSING_DYNAMIC[@]}"; do
                echo "    - $file"
            done
        fi
    else
        success "API Routeなし（静的サイトの場合は正常）"
    fi
elif [ -d "pages/api" ]; then
    success "Pages Router API Routes検出"
else
    success "API Routes なし"
fi

# 3. Prisma設定確認
echo ""
echo "🗄️  データベース設定確認..."

if [ -f "prisma/schema.prisma" ]; then
    success "Prisma schema.prismaが存在"
    
    if grep -q "rhel-openssl-3.0.x" prisma/schema.prisma; then
        success "Prisma binary targets設定済み"
    else
        error "schema.prismaにbinaryTargets設定が不足: binaryTargets = [\"native\", \"rhel-openssl-3.0.x\"]"
    fi
    
    if [ -f "lib/prisma.ts" ] || [ -f "src/lib/prisma.ts" ]; then
        success "PrismaClient初期化ファイルが存在"
    else
        warning "PrismaClient初期化ファイル (lib/prisma.ts) が見つかりません"
    fi
else
    success "Prisma未使用"
fi

# 4. 環境変数チェック
echo ""
echo "🌍 環境変数確認..."

if [ -f ".env.example" ] || [ -f ".env.template" ] || [ -f "vercel-env-template.txt" ]; then
    success "環境変数テンプレートファイルが存在"
else
    warning "環境変数テンプレートファイルがありません"
fi

if [ -f ".env.local" ]; then
    if grep -q "DATABASE_URL" .env.local 2>/dev/null; then
        success "ローカル環境のDATABASE_URL設定済み"
    fi
fi

# 5. ビルドテスト
echo ""
echo "🏗️  ビルドテスト..."

if command -v npm &> /dev/null; then
    if npm run build > /dev/null 2>&1; then
        success "npm run build 成功"
    else
        error "npm run build 失敗 - 詳細確認: npm run build"
    fi
else
    warning "npm コマンドが見つかりません"
fi

# 6. TypeScript/ESLintチェック
echo ""
echo "🔧 コード品質チェック..."

if [ -f "tsconfig.json" ]; then
    success "TypeScript設定済み"
    if command -v npx &> /dev/null; then
        if npx tsc --noEmit > /dev/null 2>&1; then
            success "TypeScript型チェック通過"
        else
            warning "TypeScript型エラーがあります - 確認: npx tsc --noEmit"
        fi
    fi
fi

if command -v npx &> /dev/null && [ -f ".eslintrc.json" ] || [ -f "eslint.config.mjs" ]; then
    if npx eslint . --ext .ts,.tsx,.js,.jsx --quiet > /dev/null 2>&1; then
        success "ESLintチェック通過"
    else
        warning "ESLintエラーがあります - 確認: npx eslint ."
    fi
fi

# 結果表示
echo ""
echo "📊 チェック結果:"
echo "    エラー: $ERRORS"
echo "    警告: $WARNINGS"

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}🎉 デプロイ準備完了です！${NC}"
    exit 0
else
    echo -e "${RED}⚠️  $ERRORS個のエラーを修正してからデプロイしてください${NC}"
    exit 1
fi