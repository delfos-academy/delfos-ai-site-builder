# Fase 2 — Arquitetura

**Objetivo.** Travar o stack e as decisões "estruturais" do projeto antes do plano. Isso evita o Claude re-discutir DB/auth/email no meio de uma feature.

**Entradas.** `BRIEF.md`, `DESIGN_SYSTEM.md`.

**Saídas.**
- `ARCHITECTURE.md` no projeto-alvo (template em [templates/ARCHITECTURE.md.tpl](../templates/ARCHITECTURE.md.tpl)).
- `CLAUDE.md` no projeto-alvo (template em [templates/CLAUDE.md.tpl](../templates/CLAUDE.md.tpl)).

## Stack locked (não re-discutir)

A skill prescreve este stack — alterá-lo significa sair do escopo da skill. Se o brief exige stack diferente, **avise o user que vai usar a skill como guia mas adaptar manualmente**.

| Camada | Escolha | Razão |
|---|---|---|
| Framework | **Next.js 16** (App Router, Fluid Compute) | RSC + Server Actions + streaming nativos |
| Runtime | **Node.js 24 LTS** (Vercel default) | Full Node, sem limitações Edge |
| Banco | **Neon Postgres** via Vercel Marketplace | Serverless, branching grátis por preview |
| ORM | **Drizzle** (`drizzle-orm/neon-http`) | Type-safe, HTTP driver (sem pool TCP) |
| Migrations | **drizzle-kit** | Generate + push |
| Styling | **Tailwind CSS v4** (CSS-first config) + tokens custom | Performance + customização total |
| Components | **shadcn/ui** | Copy-paste no repo, ownership total |
| Email | **Resend** + **React Email** | Templates em JSX, DX boa |
| Auth V0 | **Email + senha próprios + iron-session** (~150 LOC) | Zero vendor lock-in; WorkOS quando enterprise pedir SSO |
| Pagamentos | **Stripe** (Checkout + Customer Portal + Webhooks) | Padrão global |
| Tests | **Vitest** (unit) + **Playwright** (E2E) + **RTL** | Modernos, rápidos |
| Observability | **Vercel Analytics** + **Sentry** | Vitals + erros |
| AI (se houver) | **Vercel AI Gateway** (Anthropic ou Google) | Failover, observability, single billing |
| PDF | **@react-pdf/renderer** | Templates JSX |
| Rate limit | **Vercel Firewall** + (escalar) Upstash Redis | Plataforma nativa primeiro |
| Bot protection | **Vercel BotID** | Free, plug-and-play |
| Cron | **vercel.json** `crons` | Nativo |

## Passo a passo

### 1. Decidir variáveis do brief

Algumas escolhas dependem do produto. Decida com base no `BRIEF.md`:

- **Multi-tenancy?** (B2B = sim, B2C puro = não).
- **RBAC além de admin/user?** (super_admin / content_admin / support_admin?)
- **Conteúdo gerado por user é renderizado como HTML/Markdown?** (precisa sanitização).
- **Vídeo embed?** (definir provider e schema desde já).
- **Multi-idioma desde V0 ou só schema preparado?** (skill default: V0 mono, schema preparado).
- **Premium gating?** (definir regra: free aulas, paywall, trial).
- **LGPD: data export + delete account desde V0?** (default: sim, é cheap).

### 2. Decisões registradas (ADR-light)

Toda decisão **não-default** vira uma linha em `ARCHITECTURE.md` §"Decisões":

```md
### D-001 — MDX vs Markdown puro para conteúdo
**Decisão:** Markdown GFM puro via `react-markdown`.
**Motivo:** autores não-técnicos. Risco de injection com JSX livre.
**Trade-off:** sem componentes custom inline (`<Callout>`, etc) — perdemos riqueza visual.
**Reversível:** sim — schema do conteúdo é só `text`.
```

ADRs grandes (decisão estrutural com 2+ trade-offs significativos) vão para `docs/decisions/NNNN-titulo.md`.

### 3. Diagrama de alto nível

Em `ARCHITECTURE.md`, incluir um ASCII art de alto nível mostrando:

- Browser → Vercel Compute → DB / Vendors
- Camadas: Routing Middleware (proxy.ts), RSC, Server Actions, API Routes, Cron

Template pronto em [templates/ARCHITECTURE.md.tpl](../templates/ARCHITECTURE.md.tpl).

### 4. Threat model leve (STRIDE)

Não fazer threat model completo agora (vira `OPERATIONS/SECURITY.md` na Fase 5), mas listar em `ARCHITECTURE.md` §"Superfícies de ataque":

- Auth, billing, content authoring, file upload, org management.
- Para cada uma, 1 linha de "principal risco STRIDE".

### 5. CLAUDE.md

`CLAUDE.md` é carregado em toda sessão Claude Code. Deve conter:

- Contexto do projeto em 5 linhas.
- Stack locked (resumo).
- Convenções (TS strict, RSC default, server-only para DB/secrets, Zod em entradas, etc).
- "Não toque sem perguntar" (schema, proxy.ts, vercel.json, CI workflow, lib/auth/*).
- Comandos comuns.
- Glossário PT-BR ↔ EN.

Template em [templates/CLAUDE.md.tpl](../templates/CLAUDE.md.tpl).

## Quality gate

- [ ] `ARCHITECTURE.md` lista stack locked + decisões não-default + diagrama + superfícies de ataque
- [ ] `CLAUDE.md` cobre convenções, "não toque sem perguntar", comandos, glossário
- [ ] Variáveis-chave do produto decididas (multi-tenancy, RBAC, conteúdo, vídeo, i18n, gating, LGPD)
- [ ] Nenhuma decisão em aberto que bloqueie a Fase 3

## Anti-padrões

- ❌ Re-discutir stack porque "será que Astro seria melhor". Stack está locked.
- ❌ Threat model exaustivo aqui. Esse é o trabalho do `OPERATIONS/SECURITY.md` (Fase 5).
- ❌ Diagrama bonito em Mermaid/PlantUML. ASCII basta.
- ❌ Implementar nada de código. Esta fase é só documento.
