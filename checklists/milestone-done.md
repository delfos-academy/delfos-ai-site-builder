# Checklist — Milestone (antes do PR)

Aplicar a cada milestone antes de abrir PR e antes de merge.

## Conteúdo

### Critério de pronto
- [ ] Todos os requisitos do `MILESTONES/NN-*.md` marcados `- [x]`
- [ ] Para cada requisito, há teste correspondente verde
- [ ] Status do `MILESTONES/NN-*.md` atualizado

### Código
- [ ] TS strict (`noUncheckedIndexedAccess: true`) sem hacks
- [ ] `import 'server-only'` em módulos com DB/secrets
- [ ] Zod em toda entrada externa nova
- [ ] Sem comentários óbvios (só WHY não-trivial)
- [ ] Sem abstrações prematuras
- [ ] Sem feature flags / shims de compat
- [ ] Copy em {{PT_PRIMARY_LOCALE}} na UI, nomes em inglês no código

### Auth & permissions (se tocado)
- [ ] Usa `requireUser()` / `requireAdmin()` / `requireOrgRole()` (não cria mecanismo paralelo)
- [ ] Audit log em ações sensíveis
- [ ] Teste de "ação sem permissão → erro"

### Testes
- [ ] Unit tests próximos ao código (`foo.test.ts` junto de `foo.ts`)
- [ ] E2E em `tests/e2e/` cobrindo o fluxo do critério de pronto
- [ ] Mocks de vendors em `tests/mocks/` (não chamar Resend/Stripe real em CI)

### UI/UX (se tocado)
- [ ] Snapshot light + dark
- [ ] Testado em 375px e 1440px
- [ ] Skill `ui-ux-pro-max` chamada para telas novas significativas
- [ ] Skill `verify` rodada (app real, fluxo ponta-a-ponta)
- [ ] Sem violação dos do/don't do `DESIGN_SYSTEM.md`

## Quality gate (comandos)

Todos devem passar:

```bash
pnpm typecheck    # zero erros
pnpm lint         # zero warnings
pnpm test:unit    # 100% green
pnpm test:e2e     # 100% green
pnpm build        # sucesso
```

## Git

- [ ] Branch correto: `feat/M<NN>-<slug>`
- [ ] Commits Conventional (`feat(M<NN>): …`, `fix:`, `test:`, etc)
- [ ] Histórico granular (não commit gigante "everything")
- [ ] `.gitignore` respeitado (sem `.env.local` commitado)

## PR

- [ ] Título: `feat: M<NN> — <nome>`
- [ ] Body com Summary + Critério de pronto + Test plan + Screenshots
- [ ] Screenshots anexados se tocou em UI
- [ ] CI verde no PR

## Skills auxiliares (condicional)

- [ ] **`security-review`** rodada se tocou em: `lib/auth/**`, `app/api/auth/**`, `app/api/stripe/**`, `lib/billing/**`, `proxy.ts`, `lib/db/schema.ts`, `lib/email/**`, `next.config.ts`
- [ ] **`verify`** rodada se mudou UI significativa
- [ ] **`marketing-copywriter-1`** rodada se mudou copy de UI/email/marketing

## Aprovação

- [ ] User reviewou o PR
- [ ] User aprovou explicitamente o merge na sessão
- [ ] Merge feito com `gh pr merge --squash --delete-branch`
- [ ] `PLAN.md` atualizado com status `done` no milestone

## Anti-padrões

- ❌ Marcar checkbox sem testar
- ❌ "vou rodar o E2E depois"
- ❌ `eslint-disable` para passar o gate
- ❌ Auto-merge sem aprovação
- ❌ Features fora do escopo do milestone (vão pra `BACKLOG.md`)
