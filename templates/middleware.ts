import { NextRequest, NextResponse } from "next/server";

export function middleware(request: NextRequest) {
  // 認証が必要かどうかをチェック
  if (process.env.NODE_ENV === "production") {
    const basicAuth = request.headers.get("authorization");
    const url = request.nextUrl;

    if (basicAuth) {
      const authValue = basicAuth.split(" ")[1];
      const [user, pwd] = atob(authValue).split(":");

      if (
        user === process.env.BASIC_AUTH_USERNAME &&
        pwd === process.env.BASIC_AUTH_PASSWORD
      ) {
        return NextResponse.next();
      }
    }

    url.pathname = "/api/auth";
    return NextResponse.rewrite(url);
  }

  return NextResponse.next();
}

export const config = {
  matcher: [
    /*
     * 以下のパスは除外:
     * - api/auth (認証エンドポイント)
     * - _next/static (静的ファイル)
     * - _next/image (画像最適化ファイル)  
     * - favicon.ico (ファビコン)
     */
    "/((?!api/auth|_next/static|_next/image|favicon.ico).*)",
  ],
};