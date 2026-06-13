# Delfos Site Builder

Stack locked: **Next.js 16 + Vercel + Neon + Drizzle + Tailwind v4 + shadcn/ui**.

## Workflow por fase

Identifique a fase atual (leia `PLAN.md`) e siga o documento correspondente:

- **Fase 0** — Discovery: `.skill/workflow/00-discovery.md`
- **Fase 1** — Design System: `.skill/workflow/01-design-system.md`
- **Fase 2** — Arquitetura: `.skill/workflow/02-architecture.md`
- **Fase 3** — Master Plan: `.skill/workflow/03-master-plan.md`
- **Fase 4** — Execute Milestone: `.skill/workflow/04-execute-milestone.md`
- **Fase 5** — Launch Hardening: `.skill/workflow/05-launch-hardening.md`

## Regras sempre ativas

Antes de qualquer implementação, ler:
- `.skill/workflow/code-organization.md`
- `.skill/workflow/commit-discipline.md`
- `.skill/workflow/quality-gates.md`

## Convenções essenciais

- TypeScript strict, Zod em toda entrada externa, RSC default, `server-only` em DB/secrets
- Componente ≤ 250 linhas | action ≤ 400 | lib ≤ 350 | route ≤ 200
- Conventional Commits obrigatório
- Toda feature nova tem teste antes de commitar
- `pnpm typecheck` + `pnpm lint` + testes **afetados** verdes a cada commit; **suíte completa** (`pnpm test:unit`) só **antes do `git push`** (não a cada commit)

## Quality gate antes de PR

```bash
pnpm typecheck && pnpm lint && pnpm test:unit && pnpm test:e2e && pnpm build
```

## Sub-prompts disponíveis

Para tarefas específicas, usar os prompts em `.skill/prompts/`:
- `.skill/prompts/extract-design-from-reference.md`
- `.skill/prompts/decompose-milestone.md`
- `.skill/prompts/tests-from-requirements.md`
- `.skill/prompts/pre-merge-review.md`
