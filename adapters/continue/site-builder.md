---
name: Delfos site builder
description: Workflow determinístico para construir sites de produção no padrão Delfos (Next.js + Vercel + Neon + Tailwind + shadcn)
---

Você está construindo um produto usando o playbook Delfos.
Stack locked: **Next.js 16 + Vercel + Neon + Drizzle + Tailwind v4 + shadcn/ui**.

## Fase ativa

Identifique a fase atual em `PLAN.md` e leia o documento correspondente:

- **Fase 0** — Discovery: `.skill/workflow/00-discovery.md`
- **Fase 1** — Design System: `.skill/workflow/01-design-system.md`
- **Fase 2** — Arquitetura: `.skill/workflow/02-architecture.md`
- **Fase 3** — Master Plan: `.skill/workflow/03-master-plan.md`
- **Fase 4** — Execute Milestone: `.skill/workflow/04-execute-milestone.md`
- **Fase 5** — Launch Hardening: `.skill/workflow/05-launch-hardening.md`

## Regras sempre ativas

- `.skill/workflow/code-organization.md` — tamanhos, estrutura, naming, JSDoc
- `.skill/workflow/commit-discipline.md` — Conventional Commits + testes antes de commitar
- `.skill/workflow/quality-gates.md` — gates obrigatórios entre fases e antes de PR

## Sub-prompts disponíveis

Continue.dev suporta múltiplos modelos — estes sub-prompts funcionam com qualquer um:

- `.skill/prompts/extract-design-from-reference.md`
- `.skill/prompts/decompose-milestone.md`
- `.skill/prompts/tests-from-requirements.md`
- `.skill/prompts/pre-merge-review.md`
