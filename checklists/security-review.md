# Checklist — Security review

Aplicar em todo PR que toca em qualquer um destes:

- `lib/auth/**`
- `app/api/auth/**`
- `app/api/stripe/**` (ou outro webhook de billing)
- `lib/billing/**`
- `proxy.ts` (middleware)
- `lib/db/schema.ts`
- `lib/email/**`
- `next.config.ts` (headers/CSP)

> Antes da revisão manual, chamar skill `security-review` (slash command) para passar automatizado.

## Auth & sessões
- [ ] Senhas hashed com Argon2id (não bcrypt antigo, não SHA puro)
- [ ] Tokens (verify-email, password-reset, invite) armazenados como **hash** (SHA-256), nunca cru
- [ ] TTL de tokens curto (15min–24h dependendo do uso)
- [ ] Tokens são single-use (campo `used_at` marcado ao consumir)
- [ ] Reset de senha **encerra todas as sessões ativas** do user
- [ ] Anti-enumeration em forgot-password (sempre devolve 200, mesmo se email não existe)
- [ ] Cookie de sessão: `httpOnly`, `secure` (prod), `sameSite=lax`, `maxAge` ≤ 14d

## RBAC
- [ ] Toda action sensível tem `requireUser()` / `requireAdmin()` / `requireOrgRole()`
- [ ] Filter por `user_id` em queries de dados do user (não confiar só em route param)
- [ ] Teste explícito de "user sem permissão → erro" para cada ação nova

## Input validation
- [ ] Zod em **todas** as server actions e API routes novas
- [ ] Markdown sanitization: `react-markdown` sem `rehype-raw`
- [ ] File upload (se houver): MIME check + size limit

## Rate limiting
- [ ] Endpoints públicos de auth: rate limit por IP + por email
- [ ] Endpoints autenticados que custam recurso (LLM, PDF gen): rate limit por user
- [ ] Resposta 429 com `Retry-After` header

## Bot protection
- [ ] BotID nos endpoints que disparam email (signup, forgot, resend-verification, invite)
- [ ] `withBotId` no `next.config.ts`
- [ ] `initBotId` em `instrumentation-client.ts`

## Headers
- [ ] CSP sem `unsafe-eval` (`unsafe-inline` só onde estritamente necessário)
- [ ] HSTS com `max-age=63072000; includeSubDomains; preload`
- [ ] X-Frame-Options DENY (ou SAMEORIGIN se necessário)
- [ ] Referrer-Policy `strict-origin-when-cross-origin`
- [ ] Permissions-Policy bloqueando camera/microphone/geolocation se não usado

## Webhooks (Stripe etc)
- [ ] Verificação de signature obrigatória, com retorno 400 se inválida
- [ ] Idempotency: tabela `webhook_events` com pk em `event_id` para deduplicar
- [ ] Log todos os eventos (sucesso e falha)

## Secrets
- [ ] Nenhum secret no client bundle (search por `NEXT_PUBLIC_` cuidadoso)
- [ ] `.env.local` gitignored
- [ ] Sem `console.log` de secrets

## Audit log
- [ ] Toda ação admin sensível registrada em `admin_audit_log`
- [ ] Org changes (invite, role change, remove member) registradas
- [ ] Billing changes registradas

## SQL injection
- [ ] 100% queries via Drizzle (prepared statements)
- [ ] Sem string concatenation em query
- [ ] Sem `sql.raw()` com input de user

## XSS
- [ ] Sem `dangerouslySetInnerHTML` com user input
- [ ] React escapa por default — não desabilitar
- [ ] Markdown renderizado sem JSX (somente GFM via `react-markdown`)

## CSRF
- [ ] Server actions do Next 16 têm proteção nativa (origin check)
- [ ] API routes públicas com mutation precisam de CSRF token ou origin check explícito

## LGPD
- [ ] Coletando apenas o necessário (princípio da minimização)
- [ ] Endpoint `/api/me/export` cobre dado novo
- [ ] Delete account cascade FK cobre tabela nova (se foi adicionada)

## Manual smoke test
- [ ] Tentou ataque básico (SQL string em form, XSS payload em campo de texto, IDOR mudando `/[id]` na URL) — todos bloqueados

## Se tudo verde
- [ ] Skill `security-review` rodada e sem issues open
- [ ] Aprovação explícita do user para o PR
