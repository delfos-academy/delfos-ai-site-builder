# Sub-prompt: pre-merge-review

Use **antes de pedir aprovação do user no PR**. Auto-revisão estruturada do que vai ser mergeado.

## Workflow

1. Abrir PR no GitHub (sem merge).
2. Rodar este prompt contra o diff do PR.
3. Endereçar issues encontradas.
4. **Só então** pedir aprovação ao user.

## Roteiro de revisão

### 1. Critério de pronto

- [ ] Diff cobre **exatamente** o critério de pronto do `MILESTONES/NN-*.md`
- [ ] Nada extra (feature creep) — se aparecer "by the way", mover para `BACKLOG.md`
- [ ] Nada faltando — todos os requisitos têm código + teste

### 2. Convenções do projeto (CLAUDE.md)

- [ ] TS strict, sem `any` solto
- [ ] `import 'server-only'` em novos módulos com DB/secrets
- [ ] Zod em entradas externas novas
- [ ] Sem comentário óbvio (não explicar WHAT, só WHY não-trivial)
- [ ] Sem abstração prematura (3 linhas duplicadas ≠ refactor)
- [ ] Sem `console.log` esquecido
- [ ] Sem TODO sem issue
- [ ] Copy em {{PT_PRIMARY_LOCALE}} na UI, código em inglês

### 2b. Organização (rodar checklist `code-organization.md`)

- [ ] Nenhum arquivo passa do hard limit (componente 250 / action 400 / lib 350 / route 200 linhas)
- [ ] Imports ordenados via `simple-import-sort`
- [ ] Sem default export em `lib/`
- [ ] Sem função com > 5 parâmetros posicionais
- [ ] JSDoc nas superfícies públicas novas (exports do `index.ts`, server actions, componentes compartilhados)
- [ ] Public API de feature nova exposta via `lib/<feature>/index.ts`; detalhes internos não importados de fora
- [ ] Naming: `kebab-case` arquivos, `PascalCase` componentes, `use-x.ts` hooks

### 3. Segurança (se aplicável)

Se diff toca em auth/billing/dados sensíveis, rodar checklist completo de [checklists/security-review.md](../checklists/security-review.md).

Sintetizando:
- [ ] RBAC aplicado (`requireUser` / `requireAdmin` / `requireOrgRole`)
- [ ] Zod em toda entrada externa nova
- [ ] Audit log de ação sensível
- [ ] Tokens hashed (não armazenados crus)
- [ ] Rate limit em endpoint público

### 4. UI/UX (se aplicável)

- [ ] Sem violação dos do/don't do `DESIGN_SYSTEM.md`
- [ ] Light + dark testados
- [ ] 375px + 1440px testados
- [ ] Focus ring visível
- [ ] Estados loading + error + empty cobertos
- [ ] Copy revisada (sem typo, sem placeholder)

### 5. Testes

- [ ] Cada requisito do critério de pronto tem teste verde
- [ ] Failure modes cobertos (sem permissão, sem session, rate limit)
- [ ] Testes não dependem de ordem de execução
- [ ] Sem `test.skip` ou `test.only`

### 6. Performance

- [ ] Sem N+1 (queries dentro de loop)
- [ ] `next/image` em imagens novas
- [ ] Componentes pesados via `next/dynamic`
- [ ] RSC default; client component só quando necessário
- [ ] Bundle não cresceu absurdamente (rodar `pnpm build` e comparar)

### 7. DB (se mudou schema)

- [ ] Migration gerada via `pnpm db:generate` e commitada
- [ ] Aplicada no Neon dev (`pnpm db:push`)
- [ ] Não há `DROP TABLE` ou `DROP COLUMN` sem aviso
- [ ] Backfill scripts incluídos se aplicável
- [ ] Documentado em `ARCHITECTURE.md` se for decisão estrutural

### 8. Git

- [ ] Commits Conventional + granulares
- [ ] Branch nome: `feat/M<NN>-slug`
- [ ] Sem merge commit (rebase ou squash)
- [ ] `.gitignore` respeitado

### 9. Documentação

- [ ] `MILESTONES/NN-*.md` atualizado com `[x]` nas tasks
- [ ] `PLAN.md` status do milestone atualizado para `in-review`
- [ ] ADR adicionado em `docs/decisions/` se houve decisão estrutural
- [ ] README atualizado se mudou setup

## Devolução

Devolver para o user um resumo em 5 a 10 linhas:

```
PR M<NN> — <nome>
URL: <link>

Mudanças:
- <bullet 1>
- <bullet 2>

Critério de pronto: 5/5 verde
Quality gate: typecheck ✓ lint ✓ unit ✓ e2e ✓ build ✓
Segurança: rodada security-review (sem issues)
UI: snapshots light/dark/375/1440 anexados

Posso seguir com o merge?
```

## Anti-padrões

- ❌ Pedir aprovação sem ter rodado este roteiro
- ❌ "Vou consertar isso depois do merge"
- ❌ Auto-merge enquanto user revisa outra coisa
