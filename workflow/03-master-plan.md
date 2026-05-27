# Fase 3 — Master Plan

**Objetivo.** Gerar o plano mestre **token-eficiente**: um `docs/PLAN.md` enxuto (índice + critério de pronto por milestone) e N arquivos `docs/milestones/NN-*.md` com as tasks detalhadas. Cada um é carregado **só quando for trabalhado**.

**Entradas.** `BRIEF.md`, `DESIGN_SYSTEM.md`, `ARCHITECTURE.md`.

**Saídas.**
- `docs/PLAN.md` no projeto-alvo (template em [templates/PLAN.md.tpl](../templates/PLAN.md.tpl)).
- `docs/milestones/NN-<slug>.md` para cada macro-etapa (template em [templates/MILESTONE.md.tpl](../templates/MILESTONE.md.tpl)).
- `docs/WORKFLOW.md` com regras de branch/PR/merge (template em [templates/WORKFLOW.md.tpl](../templates/WORKFLOW.md.tpl)).

## Por que separar PLAN de MILESTONES

O `IMPLEMENTATION_PLAN.md` da Delfos tem 931 linhas. Ele é carregado a cada sessão do Claude (via `claudeMd` contexto). Isso é caro em tokens e **a maior parte é irrelevante para a tarefa do momento**.

Separação:
- **`docs/PLAN.md` (curto, ≤ 200 linhas)**: visão geral + lista de milestones + critério de "pronto" de cada um (1-2 linhas). Sempre carregado.
- **`docs/milestones/NN-*.md`**: tasks completas, decisões da fase, status. Carregado pelo Claude **só quando entrar nesse milestone**.

## Passo a passo

### 1. Decompor o produto em milestones

Use o subagent `milestone-planner` ([agents/milestone-planner.md](../agents/milestone-planner.md)). Em ambientes sem suporte a subagents (Cursor, uso manual), usar o sub-prompt equivalente: [prompts/decompose-milestone.md](../prompts/decompose-milestone.md).

**Regras de decomposição:**

- **6 a 10 milestones.** Menos é vago, mais é overhead.
- **Cada milestone é mergeável independente.** Não pode existir um milestone "metade de X".
- **Ordem topológica.** Sem dependências circulares. Bootstrap é sempre `00-`.
- **Cada milestone tem um "critério de pronto" verificável** em 3 linhas — isso vai virar o teste de aceitação.

**M00-bootstrap obrigatoriamente inclui:**

- Setup do package.json, configs (TS strict, ESLint, Prettier, Tailwind v4, shadcn)
- Schema do banco + Drizzle config
- Auth básico (signup/login/reset/verify) com iron-session
- CI workflow (`.github/workflows/ci.yml`) com typecheck/lint/test/build
- **Limpeza/criação da estrutura de pastas:** garantir que `docs/` existe com subpastas (`milestones/`, `operations/`, `references/`); se herdou repo bagunçado com arquivos na raiz fora da whitelist, mover pra pasta correta (ver [repo-layout.md](repo-layout.md))
- `.gitignore` com `.env*`, `.next/`, `node_modules/`, `playwright-report/`, etc

**Template Delfos** (válido para a maioria dos sites/apps SaaS):

```
00-bootstrap            Setup repo, DB schema, auth, CI/CD, layout base, limpeza de raiz
01-content-authoring    (se admin precisa criar conteúdo) CRUD de entidades
02-consumption          (se há usuário final) Páginas públicas + auth gating
03-progress             (se há tracking/estado) Eventos + cálculo + dashboard
04-interaction          (se há features interativas) Forms, runtime, gamification
05-multi-tenant         (se B2B) Orgs, seats, RBAC, invitations
06-billing              (se cobra) Stripe Checkout + Webhook + Portal
07-share-export         (se há saída para fora) Certificados, PDFs, OG dynamic
08-launch-hardening     Perf + Sec + SEO + LGPD + Monitoring
```

Adapte ao brief. Se for B2C puro, mata `05`. Se for sem conteúdo gerado, mata `01`.

### 2. Escrever `docs/PLAN.md`

Curto. Seguir [templates/PLAN.md.tpl](../templates/PLAN.md.tpl). Estrutura:

```md
# {{PROJECT_NAME}} — Plano de Implementação

## Visão geral
<3 a 5 linhas>

## Stack
ver [ARCHITECTURE.md](./ARCHITECTURE.md)

## Milestones

| # | Milestone | Detalhe | Critério de pronto |
|---|---|---|---|
| 00 | Bootstrap | [docs/milestones/00-bootstrap.md] | `pnpm build` ok, login funciona, deploy preview ativo |
| 01 | … | … | … |

## Ordem de execução
<diagrama ASCII de dependências>

## Documentos complementares
- [DESIGN_SYSTEM.md] · [ARCHITECTURE.md] · [BRIEF.md] · [REFERENCES.md]
- [OPERATIONS/PERFORMANCE.md] · [OPERATIONS/SECURITY.md] (criados na Fase 5)
- [BACKLOG.md] (features pós-V0)
```

### 3. Escrever `docs/milestones/NN-*.md`

Para cada milestone, um arquivo seguindo [templates/MILESTONE.md.tpl](../templates/MILESTONE.md.tpl):

```md
# Milestone NN — <Nome>

**Objetivo.** <1 frase>

**Critério de pronto (testável).**
- <requisito verificável 1>
- <requisito verificável 2>
- <requisito verificável 3>

**Dependências.** <quais milestones precisam estar mergeados antes>

## Tasks

### Setup
- [ ] <task>

### <Subseção temática>
- [ ] <task>

## Testes obrigatórios
- [ ] Unit test cobrindo <X>
- [ ] E2E cobrindo o fluxo do critério de pronto

## Decisões registradas durante a execução
<vazio no início, preenchido durante>

## Status
- [ ] Em andamento
- [ ] Aprovado pelo user
- [ ] Mergeado em main
```

### 4. Escrever `docs/WORKFLOW.md`

Regras de branch/PR/merge específicas do projeto. Template em [templates/WORKFLOW.md.tpl](../templates/WORKFLOW.md.tpl). Cobre:

- Naming de branch: `feat/MNN-slug`, `fix/issue-XX`
- Conventional commits
- PR description template
- Quality gate antes de merge (link para [workflow/quality-gates.md](quality-gates.md))
- Branch protection setup no GitHub (manual: CI obrigatório, no direct push)
- Política de squash vs merge commit

### 5. Mostrar `docs/PLAN.md` para o user e aguardar OK

**Não escreva os MILESTONES antes de o user aprovar o PLAN.md.** Mostrar o índice em chat, perguntar:

> "Esses são os 7 milestones que extraí do brief. Aprova ou quer adicionar/remover algum antes de eu detalhar?"

Após aprovação, gerar os arquivos `docs/milestones/NN-*.md`.

## Quality gate

- [ ] `docs/PLAN.md` ≤ 200 linhas
- [ ] 6 a 10 milestones, cada um com critério de pronto verificável
- [ ] Ordem topológica clara (sem ciclos)
- [ ] `docs/WORKFLOW.md` cobre branch/PR/merge
- [ ] Cada `docs/milestones/NN-*.md` tem ≥ 3 testes obrigatórios

## Anti-padrões

- ❌ Plano monolítico tipo `IMPLEMENTATION_PLAN.md` da Delfos (931 linhas).
- ❌ Critério de pronto vago tipo "feature funciona". Tem que ser testável.
- ❌ "Tasks" que são na verdade decisões pendentes ("Avaliar e escolher MDX editor"). Decisões vão para a fase 2 (ARCHITECTURE).
- ❌ Pular o passo de aprovação do user.
