// API Route テンプレート
// 使用方法: このファイルをコピーして、必要な処理を実装してください

// 必須設定: すべてのAPI Routeに必要
export const dynamic = 'force-dynamic';  // SSG無効化
export const runtime = 'nodejs';         // Node.jsランタイム指定

import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma"; // Prismaを使用する場合

// GET リクエストの処理
export async function GET() {
  try {
    // メイン処理をここに実装
    const data = await prisma.model.findMany(); // 例: データベースアクセス
    
    return NextResponse.json(data);
  } catch (error) {
    console.error('API Error:', error);
    return NextResponse.json(
      { error: 'Internal Server Error' }, 
      { status: 500 }
    );
  } finally {
    // データベース接続を使用した場合は必ず切断
    await prisma.$disconnect();
  }
}

// POST リクエストの処理
export async function POST(request: Request) {
  try {
    const body = await request.json();
    
    // バリデーション
    if (!body.requiredField) {
      return NextResponse.json(
        { error: 'Required field is missing' }, 
        { status: 400 }
      );
    }

    // メイン処理
    const result = await prisma.model.create({
      data: body
    });

    return NextResponse.json(result, { status: 201 });
  } catch (error) {
    console.error('API Error:', error);
    return NextResponse.json(
      { error: 'Failed to create resource' }, 
      { status: 500 }
    );
  } finally {
    await prisma.$disconnect();
  }
}

// PUT リクエストの処理
export async function PUT(request: Request) {
  try {
    const body = await request.json();
    const { id, ...updateData } = body;

    if (!id) {
      return NextResponse.json(
        { error: 'ID is required' }, 
        { status: 400 }
      );
    }

    const result = await prisma.model.update({
      where: { id },
      data: updateData
    });

    return NextResponse.json(result);
  } catch (error) {
    console.error('API Error:', error);
    return NextResponse.json(
      { error: 'Failed to update resource' }, 
      { status: 500 }
    );
  } finally {
    await prisma.$disconnect();
  }
}

// DELETE リクエストの処理
export async function DELETE(request: Request) {
  try {
    const url = new URL(request.url);
    const id = url.searchParams.get('id');

    if (!id) {
      return NextResponse.json(
        { error: 'ID is required' }, 
        { status: 400 }
      );
    }

    await prisma.model.delete({
      where: { id: parseInt(id) }
    });

    return NextResponse.json({ message: 'Deleted successfully' });
  } catch (error) {
    console.error('API Error:', error);
    return NextResponse.json(
      { error: 'Failed to delete resource' }, 
      { status: 500 }
    );
  } finally {
    await prisma.$disconnect();
  }
}