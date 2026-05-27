# {{PROJECT_NAME}} — Segurança

> Threat model, OWASP coverage, controles, compliance, incident response. Documento vivo.

## Threat model (STRIDE)

### Assets críticos

- PII de usuários ({{PII_ELEMENTS}})
- Credenciais (hashes de senha, tokens)
- {{DOMAIN_SPECIFIC_ASSET_1}}
- {{DOMAIN_SPECIFIC_ASSET_2}}

### Attackers personados

- Curioso (low-skill, scraping)
- Account taker (credential stuffing, phishing follow-up)
- Content thief (raspagem do catálogo se houver gating)
- Competitor scraper
- Malicious admin (insider threat, ex-funcionário)

### Trust boundaries

- Browser → Vercel Edge (TLS, CSP)
- Edge → Compute (Vercel internal)
- Compute → Neon (TLS, env-scoped)
- Compute → Vendors (TLS, secret-scoped)

### STRIDE por superfície

| Superfície | S | T | R | I | D | E |
|---|---|---|---|---|---|---|
| Signup/Login | BotID + rate limit | senha hashed Argon2 | logs append-only | anti-enum em forgot | rate limit | RBAC server-side |
| Content authoring | session check | Markdown puro (no JSX) | audit log | apenas admin | rate limit upload | `requireAdmin` |
| File upload | BotID | MIME + size check | audit log | signed URL | size limit | role check |
| Org management | session | Zod schema | audit log | row-level filter | rate limit | `requireOrgRole` |
| Billing webhook | Stripe signature | idempotency key | log all events | private endpoint | rate limit | restricted by sig |

## OWASP Top 10 (2021) — coverage

| # | Risk | Status | Tasks |
|---|---|---|---|
| A01 | Broken Access Control | {{A01_STATUS}} | RBAC test suite, IDOR fuzzing em `/{{ID}}` endpoints |
| A02 | Cryptographic Failures | {{A02_STATUS}} | Senha Argon2id, `IRON_SESSION_PASSWORD` ≥ 32 chars |
| A03 | Injection | {{A03_STATUS}} | Drizzle prepared statements 100%, Markdown sem JSX |
| A04 | Insecure Design | {{A04_STATUS}} | Threat model atualizado |
| A05 | Security Misconfiguration | {{A05_STATUS}} | Headers (CSP, HSTS, X-Frame-Options, Referrer-Policy, Permissions-Policy) |
| A06 | Vulnerable Components | {{A06_STATUS}} | Dependabot + auditoria mensal |
| A07 | Identification & Auth Failures | {{A07_STATUS}} | Rate limit em auth, session lifetime 14d, logout all-devices em reset |
| A08 | Software & Data Integrity | {{A08_STATUS}} | pnpm lockfile pinned, CI valida lockfile |
| A09 | Logging & Monitoring | {{A09_STATUS}} | `admin_audit_log`, Sentry alertas |
| A10 | SSRF | {{A10_STATUS}} | Allowlist de domínios em vídeo provider |

## Authentication & Session

- Senha hashed com **Argon2id** (`@node-rs/argon2`)
- Cookie `{{SESSION_COOKIE_NAME}}` (iron-session): `httpOnly`, `secure` (prod), `sameSite=lax`, `maxAge=14d`
- Cookie aponta para linha em `auth_sessions` — fonte de verdade
- Reset de senha: token SHA-256-hashed, TTL 30min, single-use, **encerra todas as sessões ativas** ao usar
- Verificação de email: token SHA-256-hashed, TTL 24h, single-use
- 2FA opcional: roadmap pós-V0 (WorkOS suporta TOTP nativo)
- Logout em todos os devices: endpoint `/api/auth/logout-all` (apaga todas as `auth_sessions` do user)

## Authorization (RBAC)

| Role | Resource | Action |
|---|---|---|
| `super_admin` | tudo | tudo |
| `content_admin` | conteúdo | CRUD |
| `support_admin` | conteúdo, users | read-only |
| `org_owner` | sua org | CRUD members, billing |
| `org_admin` | sua org | CRUD members |
| `org_member` | sua org | read |
| `user` | self | CRUD self |

Aplicado:
- **Coarse**: `proxy.ts` (middleware) — `/admin/*`, `/org/*`
- **Fine**: server actions com `requireAdmin(role?)` / `requireOrgRole(orgId, roles)`
- **DB row-level**: filter por `user_id` em queries (sem Postgres RLS por enquanto)

## Rate limiting

| Endpoint | Limit |
|---|---|
| `POST /api/auth/signup` | 3/min/IP |
| `POST /api/auth/login` | 5/min/IP |
| `POST /api/auth/forgot-password` | 5/min/IP + 3/hora/email |
| `POST /api/auth/reset-password` | 5/min/IP |
| `POST /api/auth/resend-verification` | 5/min/IP |
| Server actions autenticadas (form submit) | 60/min/user |
| Endpoint LLM (se houver) | 10–20/hora/user |

V0: in-memory sliding window (`lib/rate-limit.ts`). Upgrade: Upstash Redis (trocável sem mudar call sites).

## Input validation

- **Zod em TODAS as server actions e API routes**, sem exceção.
- Markdown sanitization: `react-markdown` com plugins `remark-gfm`, **sem** `rehype-raw` (que permite HTML).
- File upload (se houver): MIME type check, size limit, virus scan via ClamAV opcional.

## Headers

Em `next.config.ts`, headers globais:

```ts
{
  key: "Content-Security-Policy",
  value: [
    "default-src 'self'",
    "script-src 'self' 'unsafe-inline' https://vercel.live",
    "style-src 'self' 'unsafe-inline'",
    "img-src 'self' data: blob: https:",
    "font-src 'self' data:",
    "connect-src 'self' https://*.vercel.app https://*.sentry.io",
    "frame-src https://www.youtube-nocookie.com https://drive.google.com",
    "frame-ancestors 'none'",
  ].join("; ")
},
{ key: "Strict-Transport-Security", value: "max-age=63072000; includeSubDomains; preload" },
{ key: "X-Frame-Options", value: "DENY" },
{ key: "X-Content-Type-Options", value: "nosniff" },
{ key: "Referrer-Policy", value: "strict-origin-when-cross-origin" },
{ key: "Permissions-Policy", value: "camera=(), microphone=(), geolocation=()" },
```

Ajustar `frame-src` conforme providers usados.

## Secrets management

- `.env.local` gitignored
- Vercel env vars com Encrypted scope (Production + Preview)
- Rotation schedule:
  - `IRON_SESSION_PASSWORD` — anual (com session migration)
  - Vendor keys (Resend, Stripe, Sentry, AI Gateway) — anual mínimo
  - DB credentials — automático via Neon
- Sem secrets em client bundle (verificado com `next build` + bundle analyzer)

## Data protection (LGPD)

### Data inventory

| Dado | Local | Retenção | Base legal |
|---|---|---|---|
| Email, nome, image | `users` | Enquanto conta ativa | Execução de contrato |
| IPs de login | `auth_sessions` | 14 dias (sessão) | Legítimo interesse (segurança) |
| Progresso de uso | `user_progress`, `learning_events` | Enquanto conta ativa | Execução de contrato |
| Audit log | `admin_audit_log` | 1 ano | Legítimo interesse (compliance) |
| Stripe customer ID | `subscriptions` | Enquanto conta ativa | Execução de contrato |

### Right to access

- Endpoint `GET /api/me/export` — devolve JSON com **todos** os dados do user.
- Página `/account` tem botão "Exportar meus dados".

### Right to erasure

- Página `/account` → "Apagar minha conta" (confirmação dupla com input "APAGAR").
- Hard delete: cascade FK apaga `auth_sessions`, memberships, progresso, eventos, certificados.
- Tombstone anônimo em `deleted_users_log` (id + timestamp + flags estatísticos, **zero PII**) para auditoria.

### Cookie consent

- V0: somente cookie de sessão estritamente necessário. **Banner não obrigatório** se não há rastreamento/ads. Documentar na política.
- Se adicionar analytics third-party ou ads: banner obrigatório.

## Vendor security

| Vendor | Dado processado | DPA | SOC2 |
|---|---|---|---|
| Vercel | hosting | ✓ | Type 2 |
| Neon | DB | ✓ | Type 2 |
| Resend | email logs | ✓ | Type 1 |
| Stripe | billing | ✓ | Type 2 |
| Sentry | error data | ✓ | Type 2 |
| Anthropic / Google (AI Gateway) | prompts | ✓ | varia |

## Incident response

### Runbook

1. **Detect**: Sentry alerta + Vercel Analytics.
2. **Triage** (≤ 15min): severity (P0 data breach, P1 service down, P2 perf, P3 cosmetic).
3. **Contain** (P0/P1): rollback de deploy, kill switch de feature, revogar credenciais comprometidas.
4. **Investigate**: timeline em `docs/incidents/YYYY-MM-DD-<slug>.md`.
5. **Disclose**: LGPD exige **48h** para data breach. Template em `docs/templates/breach-notice.md`.
6. **Postmortem**: 5-whys, action items, em `docs/postmortems/`.

## Bot & abuse prevention

- Vercel BotID em endpoints públicos que disparam email ou criam conta
- Captcha (hCaptcha ou Cloudflare Turnstile) em casos repetidos
- IP reputation: parte do BotID
- Anomaly detection no admin panel (alerta se > X actions/min)

## Como usar este documento

1. Antes de Fase 5 final, rodar checklist completo.
2. Toda feature nova: adicionar análise STRIDE de 5 linhas.
3. Quarterly security review com este doc como guia.

## Skills relevantes

- `security-review` (slash command)
