# Fase 4 — Execute Milestone (loop)

**Objetivo.** Para cada milestone do `PLAN.md`, rodar: branch → testes → implementação → quality gate → PR → aprovação do user → merge.

**Entradas.** `docs/milestones/NN-*.md` ativo, `DESIGN_SYSTEM.md`, `ARCHITECTURE.md`, `CLAUDE.md`.

**Saídas.** Código + testes + PR mergeado em `main`.

## Loop principal

Este loop roda **uma vez por milestone**. Não pule passos.

### 1. Selecionar milestone

- Leia `PLAN.md` e encontre o próximo milestone não-mergeado.
- Cheque dependências: se o `NN-*.md` lista `Dependências: 02`, confirmar que 02 está mergeado.
- Carregue **só esse arquivo** no contexto (não os outros milestones).
- **Leia também** as seções de `docs/operations/SECURITY.md` e `docs/operations/PERFORMANCE.md` que aplicam a este milestone:
  - Toca em auth/signup/login/reset? → `OPERATIONS/SECURITY.md §Auth & Session`, `§Rate limiting`, `§Input validation`
  - Cria nova rota/página? → `OPERATIONS/PERFORMANCE.md §Rendering strategy`, `§Assets`
  - Toca em billing/webhook? → `OPERATIONS/SECURITY.md §Webhooks`, `§OWASP A05/A07`
  - Cria nova entidade no schema? → `OPERATIONS/SECURITY.md §Data protection (LGPD)` para checar se vira PII
  - Adiciona dependência? → `OPERATIONS/PERFORMANCE.md §JavaScript` (bundle budget)
- Não carregue OPERATIONS/ inteiro se só uma seção interessa — leia direcionado.

### 2. Criar branch

```bash
git checkout main
git pull
git checkout -b feat/M<NN>-<slug>
```

Naming: `feat/M00-bootstrap`, `feat/M03-progress-engine`, etc.

### 3. Escrever testes a partir dos requisitos (TDD-leve)

**Antes de implementar**, expanda os requisitos testáveis do milestone em testes concretos. Use o subagent `requirement-tester` ([agents/requirement-tester.md](../agents/requirement-tester.md)). Em ambientes sem suporte a subagents, usar o sub-prompt: [prompts/tests-from-requirements.md](../prompts/tests-from-requirements.md).

Para cada item de "Critério de pronto":

- 1 teste unitário se for função pura / cálculo / validação
- 1 teste E2E se for fluxo de usuário (Playwright)
- 1 teste de schema (Zod) se for entrada externa

Os testes **devem falhar** neste ponto (vermelho). Comite os testes:

```bash
git add tests/ ; git commit -m "test(M<NN>): testes do critério de pronto"
```

> Não TDD ortodoxo. É "garantir que o critério de pronto vira código verificável antes de eu acreditar que terminei".

### 4. Implementar — em loop "feature → teste verde → commit"

Trabalhar pelas tasks do milestone, em ordem. **Para cada feature (20-200 linhas, 1 task ou ≤ 3 sub-tasks coesas):**

Loop obrigatório (ver [commit-discipline.md](commit-discipline.md)):

```
a. (se ainda não fez) escreve teste(s) do critério/regra → falham (red)
b. git commit -m "test(<scope>): cobre <comportamento>"
c. implementa código mínimo pra passar
d. pnpm test:unit  → 100% verde (TODOS os testes, não só o novo)
e. pnpm typecheck  → zero erros
f. pnpm lint       → zero warnings
g. (se UI) snapshot conferido
h. git status → revisa arquivos específicos (sem `git add .` cego)
i. git add <files>
j. git commit -m "feat(<scope>): <descrição>"
k. marca task com [x] no MILESTONES/<NN>-*.md
l. próxima feature
```

**Bloqueios duros** (nunca commitar se):
- Algum teste do projeto está vermelho (mesmo antigo não relacionado — investiga primeiro)
- Typecheck ou lint com erros
- Feature nova sem teste correspondente
- Mensagem não é Conventional Commit

**Quando teste antigo quebra após sua mudança:**
1. Não comente, não delete, não `.skip`
2. Se sua mudança está errada → conserta o código
3. Se a regra mudou intencionalmente → atualiza o teste e **explica no corpo do commit** o que mudou e por quê

**Formato do commit:** `<type>(<scope>): <descrição em imperativo minúsculo>`. Scope com `M<NN>` quando específico do milestone.

Exemplos válidos:
- `feat(M01-courses): adiciona CRUD de cursos no admin`
- `feat(auth): adiciona reset de senha com TTL de 30min`
- `fix(M05-org): corrige contagem de seats incluindo convites pendentes`
- `test(M04): cobre os 6 tipos de exercício`
- `refactor(lib/email): extrai client Resend pra módulo dedicado`

**Regras de implementação** (eco do CLAUDE.md):
- TS strict, `noUncheckedIndexedAccess: true`
- `import 'server-only'` em módulos com DB/secrets
- Zod em toda entrada externa
- RSC default; client component só quando precisa de interatividade
- Server Actions em `app/**/actions.ts` ou inline em RSC
- Sem comentários óbvios. Só comentar **WHY** não-trivial.
- Sem feature flags / shims de compat
- Sem abstrações prematuras (3 linhas duplicadas > abstração ruim)
- Copy em PT-BR, código em inglês

**Regras de organização** (transversal — ler [code-organization.md](code-organization.md)):
- Componente `.tsx` ≤ 250 linhas hard; server action ≤ 400; lib module ≤ 350
- Estrutura por feature (`app/(area)/feature/` e `lib/feature/`), não por tipo
- Cada `lib/<feature>/` tem `index.ts` (public API); detalhes internos não exportados pelo index
- JSDoc em toda export do `index.ts`, server action, componente compartilhado
- Naming: arquivos `kebab-case`, componentes `PascalCase`, hooks `use-x.ts`
- Sem `any` solto, sem default export em `lib/`, sem função com > 5 parâmetros posicionais

### 5. UI/UX checks contínuos

Quando o milestone tocar em UI:
- Chamar `ui-ux-pro-max` skill se for tela nova significativa.
- Rodar `pnpm dev`, ver no browser em **light e dark**.
- Testar em 375px (mobile) e 1440px (desktop).
- Capturar screenshot e mostrar pro user pelo menos uma vez no meio do milestone (não só no fim).

### 6. Quality gate local

Antes de abrir PR, rodar **todo** o quality gate de [workflow/quality-gates.md](quality-gates.md).

Resumo:
```bash
pnpm typecheck   # zero erros
pnpm lint        # zero warnings
pnpm test:unit   # 100% green
pnpm test:e2e    # 100% green (precisa DB)
pnpm build       # sucesso
```

Se um teste do critério de pronto falhar, **não abra PR**. Volta para implementação.

### 7. Skills auxiliares antes do PR

- Se o milestone tocou em auth/billing/dados sensíveis: chamar `security-review` skill.
- Se o milestone tem UI: chamar `verify` skill para confirmar que rodando localmente o fluxo funciona ponta-a-ponta.
- Se o milestone gerou copy: chamar `marketing-copywriter-1`.

### 8. Atualizar `docs/milestones/NN-*.md`

Antes do PR, atualizar o arquivo do milestone:
- Marcar tasks com `- [x]`
- Preencher seção "Decisões registradas durante a execução" (ADR-lights inline)
- Não marcar "Aprovado pelo user" ainda.

### 9. Abrir PR

```bash
git push -u origin feat/M<NN>-<slug>
gh pr create --title "feat: M<NN> — <nome do milestone>" --body "$(cat <<'EOF'
## Summary
- <bullet 1>
- <bullet 2>

## Critério de pronto
- [x] <requisito 1>
- [x] <requisito 2>

## Test plan
- [ ] Unit: <comando>
- [ ] E2E: <fluxo>
- [ ] Manual: <passos>

## Screenshots
<antes/depois ou só "depois">

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

### 10. Aguardar aprovação do user

**Não fazer merge automaticamente.** Mostrar a URL do PR e perguntar:

> "PR aberto: <URL>. Quer revisar antes do merge ou posso seguir?"

Se o user aprovar:

```bash
gh pr merge --squash --delete-branch
```

Atualizar `docs/milestones/NN-*.md` com `- [x] Aprovado pelo user` e `- [x] Mergeado em main`.

### 11. Próximo milestone

Voltar ao passo 1.

## Quality gate

Aplicado por milestone. Ver [checklists/milestone-done.md](../checklists/milestone-done.md) para a versão checklist.

## Anti-padrões

- ❌ Implementar antes de escrever os testes do critério de pronto.
- ❌ Commitar tudo num único `feat:` no fim. Granular.
- ❌ Merge sem aprovação explícita do user.
- ❌ Pular `pnpm typecheck` ou `pnpm lint` "porque é uma mudança pequena".
- ❌ Carregar todos os MILESTONES no contexto — só o ativo.
- ❌ Implementar feature que não está no critério de pronto do milestone ativo. Se for boa ideia, vai para `BACKLOG.md`, não para o PR atual.
