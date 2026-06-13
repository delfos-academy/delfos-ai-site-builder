# Delfos Site Builder — Gemini

Você está construindo um produto usando o playbook Delfos.
Stack locked: **Next.js 16 + Vercel + Neon + Drizzle + Tailwind v4 + shadcn/ui**.

## Workflow por fase

Leia o documento da fase em que o projeto está (verifique `PLAN.md` se existir):

- **Fase 0** — Discovery: @.skill/workflow/00-discovery.md
- **Fase 0b** — Capturar referência: @.skill/workflow/00b-capture-reference.md
- **Fase 1** — Design System: @.skill/workflow/01-design-system.md
- **Fase 2** — Arquitetura: @.skill/workflow/02-architecture.md
- **Fase 3** — Master Plan: @.skill/workflow/03-master-plan.md
- **Fase 4** — Execute Milestone: @.skill/workflow/04-execute-milestone.md
- **Fase 5** — Launch Hardening: @.skill/workflow/05-launch-hardening.md

## Regras sempre ativas

@.skill/workflow/code-organization.md
@.skill/workflow/commit-discipline.md
@.skill/workflow/quality-gates.md

## Resumo de convenções críticas

**TypeScript:** `strict: true`, `noUncheckedIndexedAccess: true`, sem `any` solto.
**Imports:** Zod em toda entrada externa; `import 'server-only'` em módulos com DB/secrets.
**React/Next:** Server Components por padrão; `'use client'` só com interatividade real.
**Tamanhos hard:** componente `.tsx` ≤ 250 | action ≤ 400 | lib ≤ 350 | route ≤ 200 linhas.
**Commits:** Conventional obrigatório. A cada commit: `typecheck`+`lint`+testes afetados; **suíte completa só antes do `git push`** (não a cada commit).
**Testes:** toda feature nova tem teste. Unit co-located; E2E em `tests/e2e/`.

## Sub-prompts disponíveis

Para tarefas focadas, seguir os roteiros em:
- `.skill/prompts/extract-design-from-reference.md`
- `.skill/prompts/decompose-milestone.md`
- `.skill/prompts/tests-from-requirements.md`
- `.skill/prompts/pre-merge-review.md`

## Nota para VS Code (sem Firebase Studio)

O VS Code extension do Gemini não tem mecanismo de rules persistentes.
Ao iniciar uma sessão, cole o conteúdo deste arquivo no primeiro prompt,
ou referencie explicitamente o arquivo de fase: "Siga `.skill/workflow/04-execute-milestone.md`".
