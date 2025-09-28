# PR Card: workspace - Reorganize workspace feature and forms

Priority: P0 -> P1
Estimated size: L (2-4 days)

## Goal

- Move all workspace-specific UI, forms, and logic into `features/workspace/` or `app/workspace` pages that call `features/workspace/lib`.
- Migrate heavy client-only components (ImageFormClient) to remain client-only and be referenced from `features/workspace/components`.
- Consolidate shareable helpers (idb, history, schema) under `features/workspace/lib`.

## Changes

- Create `features/workspace/` with `components/`, `lib/`, `hooks/`.
- Move `app/workspace/create/_components/ImageFormClient.tsx` or leave as-is (explicitly excluded from migration if desired).
- Move page-level logic out of `page.tsx` into server actions in `features/workspace/lib`.
- Migrate forms (create/edit pages) to React Hook Form + Zod if not already.

## Files to touch (examples)

- `app/workspace/pages/[id]/page.tsx` -> delegate to `features/workspace/lib` and components
- `app/workspace/create/page.tsx`
- `app/workspace/components/*`
- `app/workspace/shared/lib/*`

## Verification

- `npm run build` passes
- Workspace pages load and editing/creating flows work (smoke test)

## Notes

- ImageFormClient can be left out per project policy; ensure import paths reference canonical locations after moves.
