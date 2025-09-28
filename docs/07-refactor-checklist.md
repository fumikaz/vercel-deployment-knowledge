# Refactor Checklist: Align Codebase to Project Structure Rules

This checklist helps you migrate the existing codebase to the agreed project structure and form development guidelines (Next.js + React Hook Form + Prisma/Supabase). It's designed to be executed incrementally and safely.

## How to use this checklist

- Work feature-by-feature. Start with low-risk areas (UI primitives, shared lib) and move to features with server actions and DB logic.
- Make small, reviewable PRs. Each PR should include tests or smoke-check steps where possible.
- Use `git` branches named like `refactor/<feature>-structure`.

## Priority levels

- P0: High — Blocks CI or causes runtime errors, or widespread imports/navigation issues.
- P1: Medium — Improves maintainability and aligns to rules; can be staged.
- P2: Low — Cosmetic, naming, or optional improvements.

---

## 1. Root-level quick checks (P0)

- [ ] Ensure `app/` only contains page/layout/route files. Move any business logic to `lib/` or `features/`.
  - Files to check: `app/**/*.ts(x)`, `app/**/lib` (if present)
- [ ] Replace relative deep imports in `app/*` that reach into sibling features with root aliases (`@/...`).
  - Run: `grep -R "from \"\.\./" app | sed -n '1,200p'` and inspect matches.
- [ ] Confirm `middleware.ts` contains only request-level logic (auth, logging). Move session helpers to `lib/`.

## 2. `lib/` alignment (P0-P1)

- [ ] `lib/prisma.ts`: single source of Prisma client. Replace scattered prisma client initializations.
- [ ] `lib/supabaseClient.ts` (or `supabase.ts`): single supabase client. Ensure both client and admin utilities are named and kept in `lib/`.
- [ ] `lib/validations/`: move Zod schemas here. For each schema:
  - [ ] Add an exported Zod schema and derived `TypeOf`.
  - [ ] Replace inline validators in forms with imports from `lib/validations/`.
- [ ] `lib/api.ts` or fetch wrappers: centralize network logic and add error handling conventions.

## 3. `components/` reorg (P1)

- [ ] `components/ui/`: move base UI primitives (Button, Input, Card, Modal). Ensure each component is framework-agnostic.
- [ ] `components/forms/`: add RHF primitives:
  - RHFForm (wrapper using FormProvider)
  - RHFInput / RHFTextArea / RHFSelect / RHFCheckbox
  - RHF controlled components should accept standard props: `name`, `label`, `rules?`, `size?`, etc.
- [ ] `components/layout/`: header, sidebar, footer. Ensure they use only `components/ui` primitives and consume navigation hooks from `lib/navigation`.

## 4. `features/` migration (P1)

For each domain feature (e.g. `auth`, `workspace`, `invites`):

- [ ] Create `features/<feature>/` with `components/`, `hooks/`, `lib/` as needed, or keep app-level `app/<feature>/...` but move logic to `features/`.
- [ ] Move feature-specific API call helpers and server action helpers into `features/<feature>/lib`.
- [ ] Migrate form components to use React Hook Form + Zod. Steps:
  - [ ] Create a Zod schema in `lib/validations/` (or `features/<feature>/lib/validations`) for each form.
  - [ ] Implement the form using `useForm({ resolver: zodResolver(schema) })`.
  - [ ] Replace custom validation logic with schema rules.
- [ ] Move any inline data fetching in `page.tsx` to server actions or `features/<feature>/lib` functions.

## 5. Pages / server actions (P0-P1)

- [ ] Convert server-side data fetching to Next.js Server Actions where appropriate.
- [ ] Keep `page.tsx` files focused on layout/UI; call server actions from client components or use Server Components that delegate to server actions.
- [ ] Migrate any `app/api` route handlers to server actions if they are only used by the app.

## 6. Routing & Navigation (P1)

- [ ] Centralize route constants in `lib/routes.ts` and use them across the app instead of hard-coded strings.
- [ ] Make `lib/navigation.ts` provide helper hooks (e.g. `useAppNavigation`) that use `usePathname`/`useRouter`. Ensure null-safety checks for `usePathname()`.

## 7. Types & Zod (P1)

- [ ] Use Zod-derived types where possible: `export type X = z.infer<typeof xSchema>`.
- [ ] Keep shared DTO types in `types/` and import them from features or `lib/`.

## 8. Testing & Linting (P1)

- [ ] Add unit tests for critical RHF form logic (happy path + 1-2 edge cases).
- [ ] Run `npm run lint` and fix rule violations. For team rules, document any ESLint rule exceptions.

## 9. Gradual migration plan (P0 -> P2)

- Phase 1 (P0): Fix build-blocking issues, consolidate `lib/supabaseClient`, `lib/prisma`, and fix import paths (aliases).
- Phase 2 (P1): Migrate common UI components and validations to `components/ui` and `lib/validations`.
- Phase 3 (P1): Migrate feature forms one-by-one to RHF + Zod; create tests and small PRs.
- Phase 4 (P2): Clean up types, rename files for consistency, add docs and examples.

## 10. Automation & Tools

- Linting: ESLint + TypeScript (apply auto-fixes with `npm run lint -- --fix` safely where applicable)
- Codemods: Consider small codemods for import path replacements (e.g. jscodeshift or ts-morph scripts) — do these behind feature branches.
- CI: Add a `refactor/check` job that runs `npm run build` and `npm run lint` for each refactor PR before merging.

## Appendix: Suggested PR checklist for each refactor

- [ ] Small, focused PR title and description
- [ ] `npm run build` passes locally
- [ ] Unit tests added/updated
- [ ] Linting passed or justified
- [ ] Smoke test steps in PR description (pages to open, flows to click)

---

File created at `vercel-deployment-knowledge/docs/07-refactor-checklist.md`.
