# Fase 5 — Launch Hardening

**Objetivo.** Levar o produto de "funcional em deploy preview" para "pronto para tráfego real". Performance, segurança, SEO, observability, LGPD.

**Entradas.** Todos os milestones anteriores mergeados em `main`. Deploy preview verde.

**Saídas.**
- `OPERATIONS/PERFORMANCE.md` no projeto-alvo (template em [templates/OPERATIONS/PERFORMANCE.md.tpl](../templates/OPERATIONS/PERFORMANCE.md.tpl)).
- `OPERATIONS/SECURITY.md` no projeto-alvo (template em [templates/OPERATIONS/SECURITY.md.tpl](../templates/OPERATIONS/SECURITY.md.tpl)).
- Páginas legais (`/privacy`, `/terms`).
- CSP/HSTS/headers configurados em `next.config.ts`.
- Rate limiting nos endpoints públicos.
- Sentry + Vercel Analytics + Speed Insights ativos.
- Lighthouse ≥ 95 em 4 páginas-chave.

## Esta fase é um milestone também

Trate como `MILESTONES/<NN>-launch-hardening.md`. Branch própria, PR, quality gate.

## Quatro pilares

### 1. Performance

Ler [templates/OPERATIONS/PERFORMANCE.md.tpl](../templates/OPERATIONS/PERFORMANCE.md.tpl) — instancie como `OPERATIONS/PERFORMANCE.md`.

**Mínimo viável:**

- [ ] **Lighthouse ≥ 95** mobile + desktop em: landing, login, dashboard, página-de-conteúdo principal
- [ ] **Core Web Vitals** monitorados via Vercel Analytics: LCP < 2.5s, INP < 200ms, CLS < 0.1
- [ ] **Bundle analyzer** rodado, sem lib gigante não-essencial (sem moment, sem lodash full)
- [ ] **`next/image` em todas as imagens**, sizes prop preenchido
- [ ] **`next/font`** para tipografia (sem `<link rel="stylesheet">` para Google Fonts)
- [ ] **Cache Components / PPR** (Next 16) onde aplicável
- [ ] **`use cache`** directive em queries de catálogo

### 2. Segurança

Ler [templates/OPERATIONS/SECURITY.md.tpl](../templates/OPERATIONS/SECURITY.md.tpl) — instancie como `OPERATIONS/SECURITY.md`.

**Mínimo viável:**

- [ ] **Vercel BotID** nos endpoints públicos que disparam email/criam conta (signup, login, forgot-password, resend-verification)
- [ ] **Rate limit** in-memory (escalar para Upstash Redis depois) em:
  - signup: 3/min/IP
  - login: 5/min/IP
  - forgot-password: 5/min/IP + 3/hora/email
  - reset-password: 5/min/IP
  - exercise submit / form submit autenticado: 60/min/user
- [ ] **CSP estrito** com allowlist para iframes (YouTube, Google Drive, Stripe se aplicável)
- [ ] **HSTS, X-Frame-Options, Referrer-Policy, Permissions-Policy** em `next.config.ts`
- [ ] **Zod em TODAS as server actions e API routes**
- [ ] **Audit log** de ações sensíveis (admin promotions, org changes, billing)
- [ ] **Secrets nunca no client bundle** — verificar com `next build` + análise de chunks
- [ ] **Dependabot** ativado no GitHub
- [ ] Chamar skill `security-review` antes do merge.

### 3. SEO

- [ ] **Metadata** correto em todas as páginas públicas: title, description, OG (1200×630), Twitter Card
- [ ] **`app/sitemap.ts`** com páginas públicas (excluir rotas auth-gated)
- [ ] **`app/robots.ts`** bloqueando `/admin`, `/api`, rotas auth-gated
- [ ] **`app/manifest.ts`** com PWA básico
- [ ] **Structured data JSON-LD**: `Organization` + `WebSite` na landing; `Product` ou `Course` por entidade pública
- [ ] **OG image dinâmica** para páginas que têm versão pública (compartilhamento) via `next/og`

### 4. LGPD / Compliance

- [ ] **Página `/privacy`** com: controlador, dados coletados, base legal, direitos do titular, DPO contato, retenção
- [ ] **Página `/terms`** com: planos, uso aceitável, propriedade intelectual, foro
- [ ] **Endpoint `/api/me/export`** que devolve JSON com todos os dados do user logado
- [ ] **"Apagar minha conta"** em `/account` com confirmação dupla (input "APAGAR" ou similar)
  - Cascade FK no schema apaga tudo
  - Antes do delete, registrar **tombstone anônimo** em `deleted_users_log` (zero PII, só id + timestamp + flags estatísticos)
- [ ] **Banner de cookies** **apenas se** houver rastreamento além do cookie de sessão. Se só sessão, documentar na política e dispensar.
- [ ] **Dados cadastrais da empresa** centralizados em `lib/placeholders/company.ts` (CNPJ, razão social, DPO, endereço) — não em `.md` lidos do disco (file tracing risk).

## Observability

- [ ] **Sentry** configurado (errors + performance) com source maps no upload
- [ ] **Vercel Analytics** ativo
- [ ] **Vercel Speed Insights** ativo
- [ ] **Status page** (Better Stack ou similar) — opcional V0
- [ ] **Alertas**: error rate > 1%, p95 latency > 1s, build failure

## Quality gate da fase

Checklist em [checklists/launch-ready.md](../checklists/launch-ready.md).

Sintetizando:
- [ ] Lighthouse ≥ 95 em 4 páginas
- [ ] Zero secrets em client bundle (confirmado com bundle analyzer)
- [ ] Rate limit testado (6º request em 1min retorna 429)
- [ ] CSP sem violações em browser console
- [ ] `security-review` skill rodada e issues endereçados
- [ ] Páginas LGPD publicadas
- [ ] Sentry recebeu erro de teste
- [ ] Sitemap + robots + manifest publicados

## Anti-padrões

- ❌ Lighthouse "depois". Mede agora.
- ❌ CSP `Content-Security-Policy: default-src *`. Estrito ou nada.
- ❌ Banner de cookies se não há rastreamento. Dark pattern.
- ❌ Endpoint de export de dados que só devolve `users.email`. Tem que ser **todos** os dados do user.
- ❌ Delete account "soft delete" sem tombstone. LGPD pede apagamento real.
- ❌ Pular `security-review` porque "é um SaaS pequeno".
