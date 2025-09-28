# PR Card: invites - Centralize invite actions & forms

Priority: P1
Estimated size: M (1-2 days)

## Goal

- Move invite-related server actions and helpers into `features/invites/lib`.
- Migrate invite forms and management UIs to React Hook Form + Zod and `components/forms` primitives.

## Changes

- Create `features/invites/` with `components/`, `lib/`, `hooks/`.
- Move `app/workspace/shared/actions/inviteActions.ts` into `features/invites/lib/repo` (or re-export from root lib)
- Ensure UI pages (`app/workspace/invites/*.tsx`) call into `features/invites/lib` and consume Zod schemas.

## Files to touch (examples)

- `app/workspace/invites/page.tsx`
- `app/workspace/invites/mine/page.tsx`
- `app/workspace/components/*` that reference invite logic

## Verification

- `npm run build` passes
- Invite creation and deletion flows work

## Notes

- Keep PR scope small: moving actions first, then forms.
