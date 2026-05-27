# {{PROJECT_NAME}} — Organização de Código

> Documento de referência sobre como o código deste repo está estruturado e por quê. Para regras universais da skill, ver também a versão de origem em [delfos-ai-site-builder/workflow/code-organization.md](https://github.com/<org>/delfos-ai-site-builder/blob/main/workflow/code-organization.md).

## Estrutura

```
app/
├── (marketing)/        site público (landing, pricing, /privacy, /terms)
├── (auth)/             /login, /signup, /forgot-password, /reset-password
├── (app)/              área autenticada (logged-in user comum)
├── (admin)/            painel /admin/*
├── api/                webhooks, endpoints REST (auth, stripe, me/export)
├── verify/[token]/     páginas públicas de verify (certificados, etc)
├── proxy.ts            middleware (auth gate)
├── layout.tsx          ThemeProvider + fontes + toaster
├── globals.css         tokens HSL (Tailwind v4 CSS-first)
└── icon.svg, manifest.ts, sitemap.ts, robots.ts

components/
├── ui/                 shadcn primitives + variantes
├── brand/              logo-mark.tsx, wordmark.tsx
├── auth/               magic-link-form, user-menu (compartilhados)
├── marketing/          hero, value-props, footer
└── <feature>/          componentes compartilhados de cada feature de domínio

lib/
├── db/                 schema.ts + client + seed
├── auth/               session, password, token, password-reset, email-verification
├── email/              resend client + send + templates/*.tsx
├── validation/         Zod schemas por área
├── <feature>/          lógica de domínio (cada feature tem index.ts como public API)
├── placeholders/       dados estáticos (company.ts, pricing.ts)
└── env.ts              env vars tipadas via Zod (uma leitura, exporta `env`)

tests/
├── e2e/                Playwright (1 spec por milestone)
├── unit/               Vitest agrupados (alternativa: co-located *.test.ts)
├── mocks/              mocks de vendors (Resend, Stripe, AI Gateway)
└── helpers/            setup compartilhado

scripts/                migrations utilitárias, capture-reference, etc
docs/
├── decisions/          ADRs (decisões com 2+ trade-offs significativos)
├── incidents/          timelines de incidentes
└── postmortems/        5-whys de incidents resolvidos
```

## Limites de tamanho (aplicados em PR)

| Tipo | Soft | Hard |
|---|---|---|
| Componente `.tsx` | 150 | 250 |
| Server action `actions.ts` | 200 | 400 |
| Lib module `.ts` | 200 | 350 |
| `route.ts` | 100 | 200 |
| Test file | 300 | 500 |
| `schema.ts` | 500 | 800 (depois quebra em `schema/`) |

## Public API por módulo (`lib/<feature>/index.ts`)

Cada feature tem `index.ts` que re-exporta APENAS o que outros consumidores podem usar. Detalhes internos ficam fora.

Exemplo (`lib/auth/index.ts`):

```ts
export { getSession, requireUser, requireAdmin } from './session';
export { hashPassword, verifyPassword } from './password';
export { requestPasswordReset, consumePasswordReset } from './password-reset';
export type { Session } from './session';
```

Consumidores: `import { requireUser } from '@/lib/auth'`. **Nunca** `import { requireUser } from '@/lib/auth/session'` em código de feature — refatoração interna quebra os call sites.

## JSDoc obrigatório

- Toda export em `lib/<feature>/index.ts`
- Toda server action
- Todo componente em `components/` (compartilhado)
- Todo tipo exportado não-trivial
- Migrations complexas

Formato:

```ts
/**
 * <O que faz em uma linha.>
 * <Detalhes opcionais — quando usar, limitações, side effects.>
 * @throws {Error} se <condição>
 */
```

## Decisões sobre **este** projeto

### Componentes RSC vs Client

- Default: **Server Component**.
- `'use client'` apenas quando: form com estado local, animação interativa, hooks de browser.
- Compor: client component **dentro** de server component, não o contrário.

### Server Actions vs API Routes

- **Server Actions** para mutations originadas no UI ({{PROJECT_NAME}}).
- **API Routes** para: webhooks (Stripe), callbacks (OAuth/SSO), endpoints públicos com Response custom.
- Não criar API route para algo que poderia ser server action.

### Estado

- Server state: **RSC + revalidatePath** (sem Zustand/Redux/Jotai globais).
- Form state: **react-hook-form + Zod resolver**.
- Toast/modal local: **useState** + Sonner.
- Sem libs de state management globais até haver um caso real que justifique.

### Convenções de domínio específicas deste projeto

{{DOMAIN_SPECIFIC_NOTES}}

## Ferramentas ativas

- ESLint flat config: `eslint.config.mjs`
  - `eslint-plugin-import`
  - `simple-import-sort`
  - `eslint-plugin-jsdoc`
- Prettier: `.prettierrc` + `prettier-plugin-tailwindcss`
- Husky + lint-staged: pre-commit roda eslint + prettier no diff
- TypeScript: `strict: true`, `noUncheckedIndexedAccess: true`, `noImplicitOverride: true`
- Knip: detect dead exports (rodar quarterly)

## Como navegar a codebase (para humanos)

Procurando algo:

- **"Onde está a lógica de X?"** → `lib/<x>/` é a primeira tentativa.
- **"Onde a UI de X mora?"** → `app/(<area>)/x/page.tsx` se for página; `components/<x>/` se for compartilhado.
- **"Como fluem dados?"** → page (RSC) → server action → lib function → db. Quase sempre.
- **"Onde estão as decisões?"** → `ARCHITECTURE.md` §Decisões + `docs/decisions/`.

## Como o Claude navega (para IA)

Em CLAUDE.md está mapeado o que **não tocar sem perguntar** e as convenções principais. Antes de mudar algo grande, lê `MILESTONES/` ativo + `ARCHITECTURE.md`.

Quando preciso entender uma feature do zero:
1. `Read lib/<feature>/index.ts` (public API)
2. `Read app/<area>/<feature>/page.tsx` (consumo)
3. `Grep` por uso entre os dois para entender boundary
