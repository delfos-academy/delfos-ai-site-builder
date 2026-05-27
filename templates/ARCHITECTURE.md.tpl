# {{PROJECT_NAME}} — Arquitetura

> Decisões estruturais. Stack locked. Não re-discutir sem motivo forte.

## Stack

| Camada | Escolha |
|---|---|
| Framework | Next.js 16 (App Router, Fluid Compute) |
| Runtime | Node.js 24 LTS (Vercel default) |
| Banco | Neon Postgres (via Vercel Marketplace) |
| ORM | Drizzle (`drizzle-orm/neon-http`) |
| Migrations | drizzle-kit |
| Styling | Tailwind CSS v4 + tokens HSL |
| Components | shadcn/ui (copy-paste no repo) |
| Email | Resend + React Email |
| Auth V0 | Email + senha próprios + iron-session |
| Pagamentos | {{PAYMENT_PROVIDER}} (Stripe ou "N/A" no V0) |
| Tests | Vitest (unit) + Playwright (E2E) + RTL |
| Observability | Vercel Analytics + Sentry |
| AI Gateway | {{AI_GATEWAY}} (Vercel AI Gateway com {{AI_MODEL}} ou "N/A") |
| Rate limit | Vercel Firewall + (escalar) Upstash Redis |
| Bot protection | Vercel BotID |
| Cron | vercel.json `crons` |
| PDF | @react-pdf/renderer |

## Decisões registradas (ADR-light)

### D-001 — {{DECISION_1_TITLE}}
**Decisão:** {{DECISION_1_OUTCOME}}
**Motivo:** {{DECISION_1_REASON}}
**Trade-off:** {{DECISION_1_TRADEOFF}}
**Reversível:** {{DECISION_1_REVERSIBLE}}

### D-002 — {{DECISION_2_TITLE}}
**Decisão:** {{DECISION_2_OUTCOME}}
**Motivo:** {{DECISION_2_REASON}}
**Trade-off:** {{DECISION_2_TRADEOFF}}
**Reversível:** {{DECISION_2_REVERSIBLE}}

> ADRs grandes (estruturais com 2+ trade-offs significativos) vão para `docs/decisions/NNNN-titulo.md`.

## Variáveis do produto (decididas)

- **Multi-tenancy:** {{MULTI_TENANCY}}
- **RBAC:** {{RBAC_ROLES}}
- **Conteúdo gerado por user:** {{USER_CONTENT_FORMAT}}
- **Vídeo embed:** {{VIDEO_PROVIDER}}
- **Multi-idioma:** {{I18N_STRATEGY}}
- **Premium gating:** {{GATING_RULE}}
- **LGPD export + delete:** {{LGPD_V0}}

## Arquitetura de alto nível

```
┌─────────────────────────────────────────────────────────────────┐
│                  Browser (Next.js App Router)                    │
│  ┌──────────────┐  ┌──────────────┐  ┌─────────────────────┐    │
│  │   Marketing  │  │   App        │  │   Admin Panel       │    │
│  │   /          │  │   /dashboard │  │   /admin/*          │    │
│  └──────────────┘  └──────────────┘  └─────────────────────┘    │
└───────────────────────────┬─────────────────────────────────────┘
                            │ RSC + Server Actions
┌───────────────────────────▼─────────────────────────────────────┐
│              Vercel Fluid Compute (Node.js 24)                  │
│  Routing (proxy.ts) · API Routes · Server Actions · Cron        │
└───────────┬─────────────┬──────────────┬────────────┬───────────┘
            │             │              │            │
┌───────────▼──┐ ┌────────▼─────┐ ┌──────▼──────┐ ┌──▼─────────┐
│ Neon Postgres│ │   Resend     │ │   Stripe    │ │ AI Gateway │
│  (Drizzle)   │ │   (email)    │ │  (billing)  │ │   (LLM)    │
└──────────────┘ └──────────────┘ └─────────────┘ └────────────┘
```

## Camadas

- **Edge (Routing Middleware / `proxy.ts`):** primeira linha de auth gate, redirect anônimo, cookies de sessão.
- **App Router Server Components:** páginas renderizadas no servidor, fetch direto do DB.
- **Server Actions:** mutations + form submits sem montar API routes manuais.
- **API Routes:** apenas para endpoints públicos (webhooks Stripe, callbacks) ou que precisem de Response custom.
- **DB:** Neon Postgres com Drizzle. Sem ORM relations no V0 — joins explícitos pra clareza/performance.

## Schema inicial (resumo)

> Source of truth completa em `lib/db/schema.ts`. Aqui só o overview.

Entidades base esperadas:

- `users` (id, email unique, name, image, locale_pref, created_at, email_verified_at)
- `auth_sessions` (cookie aponta pra cá; fonte de verdade da sessão)
- `password_reset_tokens` (token_hash, expires_at, used_at)
- `email_verification_tokens` (token_hash, expires_at, used_at)
{{DOMAIN_ENTITIES_LIST}}

Toda tabela de conteúdo tem coluna `locale` desde V0 (default `pt-BR`).

## Superfícies de ataque (STRIDE leve)

Análise completa em [OPERATIONS/SECURITY.md](./OPERATIONS/SECURITY.md) (Fase 5). Aqui só o mapa:

| Superfície | Principal risco STRIDE | Controle inicial |
|---|---|---|
| Auth (signup/login/reset) | Spoofing + Information Disclosure | BotID + rate limit + token hash |
| Content authoring | Tampering (XSS via MDX) | Markdown puro, sem JSX livre |
| File upload (se houver) | Tampering + DoS | MIME check + size limit + Vercel Blob |
| Org management | Elevation of Privilege | `requireOrgRole` em todas as actions |
| Billing webhook | Spoofing | Signature verification obrigatória |
| Admin panel | Elevation of Privilege | `requireAdmin` + audit log |

## "Não toque sem perguntar"

- `lib/db/schema.ts` — migration + revisão obrigatória
- `proxy.ts` — afeta toda request
- `vercel.json` — afeta deploy
- `.github/workflows/ci.yml` — afeta CI de todos
- `lib/auth/session.ts` e correlatos — core de segurança
- `next.config.ts` (headers/CSP) — afeta segurança

## Diretrizes operacionais

- Branches preview no Vercel = automatic preview deploy + Neon branch
- `main` faz deploy direto em produção (cuidado com merges)
- Env vars: `.env.example` documenta tudo; valores reais em Vercel encrypted
