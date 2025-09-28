# PR Card: pages - Page management & form migration

Priority: P1
Estimated size: M (1-2 days)

## Goal

- Migrate page-edit/create forms to React Hook Form + Zod.
- Move page-related helpers (idb, recentPages) into `features/pages/lib`.

## Changes

- Create `features/pages/` with `components/`, `lib/`, `hooks/`.
- Move `app/workspace/pages/*` helpers into `features/pages/lib` and update imports.
- Replace inline form validations with Zod schemas in `lib/validations/pages`.

## Files to touch (examples)

- `app/workspace/pages/page.tsx`
- `app/workspace/pages/[id]/page.tsx`
- `app/workspace/pages/components/*`

## Verification

- `npm run build` passes
- Page create/edit flows work locally

## Notes

- If a page component depends on client-only heavy libs, keep them client-only and document in PR.
