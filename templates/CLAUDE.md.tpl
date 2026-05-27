# CLAUDE.md — Convenções para sessões futuras de Claude Code

Este arquivo é carregado automaticamente em toda sessão. Mantém o agent alinhado com o projeto.

## Contexto rápido

**{{PROJECT_NAME}}** é {{PROJECT_ONE_LINER}}. Idioma V0: **{{PT_PRIMARY_LOCALE}}**. Hospedado na Vercel.

**Founder:** {{FOUNDER_NAME}} ({{FOUNDER_EMAIL}}). Fala {{FOUNDER_LANGUAGE}}.

Plano mestre: [PLAN.md](./PLAN.md). Detalhes por etapa em [MILESTONES/](./MILESTONES/). Ler antes de propor mudanças grandes.

## Stack (decidido — não re-discutir sem motivo forte)

Ver [ARCHITECTURE.md](./ARCHITECTURE.md). Resumo:

- Next.js 16 (App Router, Fluid Compute), Node 24 LTS
- Neon Postgres + Drizzle ORM (`drizzle-orm/neon-http`)
- Tailwind v4 + shadcn/ui
- **Auth V0: email + senha próprios + iron-session** (~150 LOC)
- Resend para emails transacionais
- Vercel: AI Gateway, Blob, Firewall, BotID
- Stripe (B2C billing — quando aplicável)
- Vitest + Playwright

## Convenções

### TypeScript
- `strict: true`, `noUncheckedIndexedAccess: true`
- Path alias `@/*` (raiz do repo)
- `import 'server-only'` em módulos com secrets/DB
- Zod em toda entrada externa (form, route, action)

### React/Next
- Server Components por padrão; client components só quando precisa de interatividade
- Server Actions em `app/**/actions.ts` ou inline em RSC
- Forms: react-hook-form + zod resolver
- Erros: lançar `Error`/subclass; capturar em `error.tsx`
- Cada segment tem `loading.tsx` e `error.tsx`

### Code style
- Não escrever comentários óbvios (não comentar o WHAT, só o WHY não-trivial)
- Não criar arquivos `.md` de notas/análise sem ser pedido
- Não criar abstrações prematuras (3 linhas duplicadas > abstração ruim)
- Não adicionar feature flags / shims de compat se podemos só editar
- Nomes em inglês no código; copy em {{PT_PRIMARY_LOCALE}} na UI

### Organização (ver [CODE_ORGANIZATION.md](./CODE_ORGANIZATION.md))
- Estrutura **por feature**, não por tipo
- Tamanho hard: componente `.tsx` ≤ 250 linhas, server action ≤ 400, lib `.ts` ≤ 350
- Cada `lib/<feature>/` tem `index.ts` que re-exporta a "API pública"; consumidores importam do index
- JSDoc obrigatório em: exports do `index.ts`, server actions, componentes compartilhados, tipos exportados não-triviais
- Arquivos `kebab-case`; componentes export `PascalCase`; hooks `use-x.ts`
- Sem `any` solto, sem default export em `lib/`, sem função com > 5 parâmetros posicionais
- Imports ordenados (side-effect → node → external → `@/` → relativo → type-only) — `eslint-plugin-import` + `simple-import-sort` ativos

### Banco
- Schema fonte única: `lib/db/schema.ts`
- Toda tabela de conteúdo tem coluna `locale` (V0 só usa `{{PT_PRIMARY_LOCALE}}`, mas o schema já está pronto)
- Migrations: `pnpm db:generate` → commitar SQL → `pnpm db:push`
- Queries via Drizzle, sem ORM relations (joins explícitos)

### Auth
- **Sempre** use `getSession()` / `requireUser()` / `requireAdmin()` de `lib/auth/session.ts`
- Não criar mecanismos paralelos de auth
- Cookie `{{SESSION_COOKIE_NAME}}` (iron-session) aponta para uma linha em `auth_sessions` — essa é a fonte de verdade

### Email
- **Sempre** use `sendEmail()` de `lib/email/send.ts` (Resend)
- Templates em `lib/email/templates/*.tsx` com React Email
- Copy em {{PT_PRIMARY_LOCALE}}, tom profissional adulto

### Testes
- Unit tests próximos ao código (`foo.ts` + `foo.test.ts`)
- E2E em `tests/e2e/`
- Toda mudança de auth precisa de teste novo ou atualizado
- Mocks de vendors em `tests/mocks/`

### Commits
- Conventional Commits: `feat:`, `fix:`, `chore:`, `refactor:`, `test:`, `docs:`
- Branch naming: `feat/M<NN>-<slug>`, `fix/<short>`
- Sem push direto em `main`. Sempre PR.

## Skills úteis nesse projeto

- `ui-ux-pro-max` — para qualquer mudança visual significativa
- `frontend-design` — para componentes distintos e autorais
- `marketing-copywriter-1` — para qualquer copy (UI, email, marketing)
- `verify` — sempre rodar antes de claim "está pronto" em UI
- `security-review` — antes de PR que toca auth/billing/dados sensíveis
- `code-review` — segundo opinião em diff grande

## Não toque sem perguntar

- `lib/db/schema.ts` — mudança aqui exige migration + revisão
- `proxy.ts` (Next 16 renomeou `middleware.ts` → `proxy.ts`) — afeta toda request
- `vercel.json` — afeta deploy
- `.github/workflows/ci.yml` — afeta CI de todos
- `lib/auth/session.ts` e correlatos — core de segurança
- `next.config.ts` (headers/CSP) — afeta segurança

## Comandos mais comuns

```bash
pnpm dev              # dev server
pnpm typecheck        # tsc
pnpm lint             # eslint
pnpm test:unit        # vitest
pnpm test:e2e         # playwright
pnpm db:push          # apply schema
pnpm db:studio        # explorar banco
```

## Quando finalizar uma task

1. Rodar `pnpm typecheck` + `pnpm lint` + `pnpm test:unit`
2. Atualizar `MILESTONES/<NN>-*.md` marcando `- [x]` nas tasks completadas
3. Commit com mensagem Conventional
4. Se for fim de milestone, abrir PR e atualizar `PLAN.md` com status

## Vocabulário do produto ({{PT_PRIMARY_LOCALE}} ↔ EN no código)

| {{PT_PRIMARY_LOCALE}} (UI) | EN (código) |
|---|---|
| {{TERM_1_PT}} | {{TERM_1_EN}} |
| {{TERM_2_PT}} | {{TERM_2_EN}} |
| {{TERM_3_PT}} | {{TERM_3_EN}} |
| Aluno | user (com role) |
| Administrador | admin |
| Organização | organization (org) |
| Assento | seat |
| Convite | invitation |
| Concluído | completed |
| Em andamento | in_progress |
| Rascunho | draft |
| Publicado | published |
