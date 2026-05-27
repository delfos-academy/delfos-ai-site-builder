# Fase 4 — Execute Milestone (loop)

**Objetivo.** Para cada milestone do `PLAN.md`, rodar: branch → testes → implementação → quality gate → PR → aprovação do user → merge.

**Entradas.** `MILESTONES/NN-*.md` ativo, `DESIGN_SYSTEM.md`, `ARCHITECTURE.md`, `CLAUDE.md`.

**Saídas.** Código + testes + PR mergeado em `main`.

## Loop principal

Este loop roda **uma vez por milestone**. Não pule passos.

### 1. Selecionar milestone

- Leia `PLAN.md` e encontre o próximo milestone não-mergeado.
- Cheque dependências: se o `NN-*.md` lista `Dependências: 02`, confirmar que 02 está mergeado.
- Carregue **só esse arquivo** no contexto (não os outros milestones).

### 2. Criar branch

```bash
git checkout main
git pull
git checkout -b feat/M<NN>-<slug>
```

Naming: `feat/M00-bootstrap`, `feat/M03-progress-engine`, etc.

### 3. Escrever testes a partir dos requisitos (TDD-leve)

**Antes de implementar**, expanda os requisitos testáveis do milestone em testes concretos. Use [prompts/tests-from-requirements.md](../prompts/tests-from-requirements.md).

Para cada item de "Critério de pronto":

- 1 teste unitário se for função pura / cálculo / validação
- 1 teste E2E se for fluxo de usuário (Playwright)
- 1 teste de schema (Zod) se for entrada externa

Os testes **devem falhar** neste ponto (vermelho). Comite os testes:

```bash
git add tests/ ; git commit -m "test(M<NN>): testes do critério de pronto"
```

> Não TDD ortodoxo. É "garantir que o critério de pronto vira código verificável antes de eu acreditar que terminei".

### 4. Implementar

Trabalhar pelas tasks do milestone, em ordem. Após cada bloco lógico (uma feature pequena, um endpoint, um componente):

```bash
git commit -m "feat(M<NN>): <descrição>"
```

**Não junte tudo num commit gigante.** Histórico granular ajuda a reverter se uma parte específica der ruim.

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

### 8. Atualizar `MILESTONES/NN-*.md`

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

Atualizar `MILESTONES/NN-*.md` com `- [x] Aprovado pelo user` e `- [x] Mergeado em main`.

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
