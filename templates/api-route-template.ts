// API Route テンプレート
// 使用方法: このファイルをコピーして、必要な処理を実装してください

// 必須設定: すべてのAPI Routeに必要
export const dynamic = "force-dynamic"; // SSG無効化
export const runtime = "nodejs"; // Node.jsランタイム指定

import { NextResponse } from "next/server";

/*
  API Route テンプレート

  このファイルはテンプレート用で、実際のプロジェクトでは
  `@/lib/prisma` などの実装をコピーして使用してください。

  例（コピーして使用）：

  import { prisma } from "@/lib/prisma";

  export async function GET() {
    try {
      const data = await prisma.YOUR_MODEL.findMany();
      return NextResponse.json(data);
    } catch (error) {
      return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
    } finally {
      await prisma.$disconnect();
    }
  }

*/

// 最小限のスタブを置いて型チェックを通過させる
export async function GET() {
  return NextResponse.json({ message: "template" });
}
