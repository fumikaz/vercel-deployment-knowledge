# PR Card: admin - Admin pages & reward logs

Priority: P2 -> P1
Estimated size: S-M (half day - 1 day)

## Goal

- Consolidate admin-only logic into `features/admin/` and ensure admin pages call server actions from that feature.
- Make `rewardLogActions` and similar admin utilities live under `features/admin/lib`.

## Changes

- Create `features/admin/` with `components/`, `lib/`.
- Move `app/workspace/admin/reward-logs/page.tsx` related helpers/actions to the new feature.

## Files to touch (examples)

- `app/workspace/admin/reward-logs/page.tsx`
- `app/workspace/admin/*`

## Verification

- `npm run build` passes
- Admin reward logs page displays logs correctly

## Notes

- Admin pages are lower priority for UX polish but important for backend consistency.
