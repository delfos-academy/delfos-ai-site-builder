# Checklist — Launch Ready (Fase 5 done)

Pronto para tráfego real.

## Performance

- [ ] Lighthouse ≥ 95 (mobile **e** desktop) em:
  - [ ] `/` (landing)
  - [ ] `/login`
  - [ ] `/dashboard`
  - [ ] Página de conteúdo principal
- [ ] LCP < 2.5s em todas as 4 (RUM via Vercel Analytics)
- [ ] INP < 200ms
- [ ] CLS < 0.1
- [ ] Bundle JS de cada rota ≤ budget definido em `OPERATIONS/PERFORMANCE.md`
- [ ] `next/image` em **todas** as imagens (sem `<img>` direto)
- [ ] `next/font` para tipografia (sem `<link rel="stylesheet">` Google Fonts)

## Segurança

- [ ] Vercel BotID nos endpoints públicos que disparam email/criam conta
- [ ] Rate limit testado em endpoint de auth (6º request em 1min retorna **429**)
- [ ] CSP configurado em `next.config.ts`
- [ ] CSP **sem violações** verificadas em browser console em todas as páginas-chave
- [ ] HSTS + X-Frame-Options + Referrer-Policy + Permissions-Policy configurados
- [ ] Zod em **todas** as server actions / API routes (auditado)
- [ ] Audit log de ações sensíveis funcionando
- [ ] Zero secrets em client bundle (verificado com `next build` + chunks analysis)
- [ ] Dependabot ativado no GitHub
- [ ] Skill `security-review` rodada e issues endereçados

## SEO

- [ ] Metadata em todas as páginas públicas (title, description, OG, Twitter)
- [ ] `app/sitemap.ts` publicado e válido
- [ ] `app/robots.ts` bloqueando rotas privadas (`/admin`, `/api`, auth-gated)
- [ ] `app/manifest.ts` (PWA básico)
- [ ] OG image 1200×630 nas páginas-chave
- [ ] JSON-LD `Organization` + `WebSite` na landing
- [ ] OG image dinâmica via `next/og` em páginas com versão pública (se aplicável)

## LGPD / Compliance

- [ ] Página `/privacy` publicada com todos os campos exigidos pela LGPD
- [ ] Página `/terms` publicada
- [ ] DPO contato visível
- [ ] Endpoint `/api/me/export` testado (devolve JSON com todos os dados do user)
- [ ] "Apagar minha conta" em `/account` testado (cria tombstone anônimo, cascade FK, sem PII no log)
- [ ] Banner de cookies: **apenas se** houver rastreamento além do cookie de sessão
- [ ] Dados cadastrais da empresa em módulo TS (não em `.md`)

## Observability

- [ ] Sentry configurado (errors + performance) com source maps no upload
- [ ] Sentry recebeu um erro de teste em prod
- [ ] Vercel Analytics ativo
- [ ] Vercel Speed Insights ativo
- [ ] Alertas configurados: error rate > 1%, p95 latency > 1s, build failure

## CI/CD

- [ ] CI passa em PR (typecheck + lint + unit + build)
- [ ] Branch protection ativada em `main` (CI obrigatório)
- [ ] Deploy preview funciona em PRs
- [ ] Deploy de produção funciona em merge para `main`

## Email & comunicação

- [ ] Domínio verificado no Resend (`onboarding@resend.dev` é sandbox)
- [ ] `EMAIL_FROM` aponta para domínio verificado
- [ ] Templates: signup welcome, verify-email, password-reset, invitation (se aplicável)
- [ ] Email envia em prod (testar com email real, não @resend.dev)

## Documentação

- [ ] `README.md` do projeto com instruções de setup
- [ ] `CLAUDE.md` atualizado
- [ ] `PLAN.md` marca milestone 08 como `done`
- [ ] `OPERATIONS/PERFORMANCE.md` com audits mais recentes
- [ ] `OPERATIONS/SECURITY.md` com threat model atualizado

## Smoke test final

- [ ] Signup → verify email → login → fluxo principal → logout → reset password → login de novo (ponta-a-ponta em prod)
- [ ] `/privacy`, `/terms`, `/pricing` carregam sem erro
- [ ] 404 em rota inexistente
- [ ] Mobile (real device, não só devtools) funciona

## Anti-padrões

- ❌ "Lighthouse depois"
- ❌ "CSP em modo report-only"
- ❌ "Banner de cookies como precaução" (dark pattern se não há rastreamento)
- ❌ Sentry sem source maps
- ❌ Domínio do Resend ainda em sandbox em prod
