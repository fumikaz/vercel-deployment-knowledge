# Project Structure and Form Development Guidelines

This document describes the recommended project structure and form development guidelines for Next.js projects using React Hook Form, Zod, Prisma, and Supabase.

## Directory Structure Rules

- `app/` : Next.js App Router root and UI layouts only
  - Manage pages (`page.tsx`), layouts (`layout.tsx`), and API routes (`route.ts`) here
  - Keep data fetching and business logic out of `app/` root; delegate them to `lib/` or `features/`

- `components/` : Reusable UI components
  - `ui/` : Base UI primitives (Button, Input, Card, Modal, etc.)
  - `forms/` : React Hook Form specific components (FormProvider, RHFInput, RHFSelect, etc.)
  - `layout/` : Header, Sidebar and layout-related components

- `features/` : Feature/domain-oriented code organization
  - Examples: `auth/`, `users/`, `dashboard/`
  - Each feature should contain:
    - `components/` : UI components specific to the feature
    - `hooks/` : feature-scoped custom hooks
    - `lib/` : service logic (API clients, form logic, validation) specific to the feature

- `lib/` : Shared logic and service connectors
  - `prisma.ts` : Prisma client initialization (node runtime)
  - `supabase.ts` : Supabase client initialization (auth, storage)
  - `api.ts` : fetch wrappers (for SWR/React Query)
  - `validations/` : Zod schemas (reused by RHF resolvers)
  - `utils.ts` : general utilities

- `hooks/` : Globally reusable custom hooks
  - Examples: `useAuth()`, `useToggle()`, `usePagination()`

- `types/` : TypeScript type definitions
  - Compose Prisma generated types and Zod-derived types here

- `styles/` : CSS, Tailwind configuration
  - `globals.css`, `theme.css`, tailwind config files

- `tests/` : Test suites
  - `unit/` : Jest/Vitest unit tests
  - `e2e/` : Playwright/Cypress end-to-end tests

- `middleware.ts` : Next.js middleware for auth/logging

## Form Development Guidelines

- Use React Hook Form as the standard form library
- Validation should be Zod-based and placed under `lib/validations/`
- Place RHF-specific components in `components/forms/` (RHFInput, RHFSelect, RHFRadio, etc.)
- Use `FormProvider` inside each feature's component tree to scope forms to the feature
- Prefer server actions (Next.js Server Actions) for submitting and persisting data when appropriate

## Notes and Best Practices

- Keep `app/` layer UI-focused. Business logic, DB access, and network calls should live in `lib/` or `features/`.
- Keep components small and composable. Reuse primitives from `components/ui/` and RHF helpers from `components/forms/`.
- Organize features by domain to make code ownership and scaling easier.
- Keep Zod schemas as the single source of truth for validation and derive TypeScript types from them when possible.

## Sharing this doc

- This file is stored at `vercel-deployment-knowledge/docs/06-project-structure.md` for team reference and to be included in your deployment knowledge base.
