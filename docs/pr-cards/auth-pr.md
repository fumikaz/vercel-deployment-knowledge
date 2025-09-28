# PR Card: auth - Consolidate auth logic & migrate forms

Priority: P0 -> P1
Estimated size: M (1-2 days)

## Goal

- Consolidate authentication-related logic into `features/auth/` and `lib/`.
- Ensure `app/auth/*` pages are UI-only and call server actions or functions from `features/auth/lib`.
- Migrate development auth forms to React Hook Form + Zod if not already.

## Changes

- Create `features/auth/` with:
  - `components/` for auth-specific UI
  - `lib/` for server actions and helper functions (e.g. `ensureUser`, `setCookieAction` wrappers)
- Move `app/auth/page.tsx` logic that calls `supabase` into `features/auth/lib` as server actions or helpers.
- Ensure `supabaseClient` is used from `lib/supabaseClient.ts`.
- Replace inline validation with Zod schemas under `lib/validations/auth/*.ts`.

## Files to touch (examples)

- `app/auth/page.tsx` (UI only)
- `app/auth/invite/[token]/page.tsx` (UI -> call features)
- `app/workspace/shared/actions/authActions.ts` -> consider moving wrappers to `features/auth/lib` and re-exporting

## Verification

- `npm run build` passes
- Login flow (Google OAuth) shows UI and redirects (middleware handles redirect)
- Dev auth forms (if shown) validate correctly and call server actions

## Notes

- Keep PR small: move logic first, then update forms in a follow-up PR if needed.
