# {{PROJECT_NAME}} — Plano de Implementação

> Documento mestre. Índice fino — detalhes em `MILESTONES/`. Última atualização: {{LAST_UPDATED}}.

## Visão geral

{{PROJECT_OVERVIEW_3_5_LINES}}

## Princípios não-negociáveis

Ver [BRIEF.md](./BRIEF.md) §"Princípios". Reforçados aqui pra contexto Claude:

1. Funcional desde V0 — 5 features impecáveis > 15 meia-bocas
2. Aesthetic equals functional
3. Comfort em sessões longas (dark default, WCAG 2.2 AA)
4. Tests desde dia 1
5. {{CUSTOM_PRINCIPLE_5}}

## Stack

Ver [ARCHITECTURE.md](./ARCHITECTURE.md) (mesma pasta `docs/`). Locked.

## Milestones

| # | Milestone | Detalhe | Critério de pronto (resumido) | Status |
|---|---|---|---|---|
| 00 | Bootstrap | [./milestones/00-bootstrap.md](./milestones/00-bootstrap.md) | Build verde + login + deploy preview ativo | {{M00_STATUS}} |
| 01 | {{M01_NAME}} | [./milestones/01-{{M01_SLUG}}.md](./milestones/01-{{M01_SLUG}}.md) | {{M01_DONE_LINE}} | {{M01_STATUS}} |
| 02 | {{M02_NAME}} | [./milestones/02-{{M02_SLUG}}.md](./milestones/02-{{M02_SLUG}}.md) | {{M02_DONE_LINE}} | {{M02_STATUS}} |
| 03 | {{M03_NAME}} | [./milestones/03-{{M03_SLUG}}.md](./milestones/03-{{M03_SLUG}}.md) | {{M03_DONE_LINE}} | {{M03_STATUS}} |
| 04 | {{M04_NAME}} | [./milestones/04-{{M04_SLUG}}.md](./milestones/04-{{M04_SLUG}}.md) | {{M04_DONE_LINE}} | {{M04_STATUS}} |
| 05 | {{M05_NAME}} | [./milestones/05-{{M05_SLUG}}.md](./milestones/05-{{M05_SLUG}}.md) | {{M05_DONE_LINE}} | {{M05_STATUS}} |
| 06 | {{M06_NAME}} | [./milestones/06-{{M06_SLUG}}.md](./milestones/06-{{M06_SLUG}}.md) | {{M06_DONE_LINE}} | {{M06_STATUS}} |
| 07 | {{M07_NAME}} | [./milestones/07-{{M07_SLUG}}.md](./milestones/07-{{M07_SLUG}}.md) | {{M07_DONE_LINE}} | {{M07_STATUS}} |
| 08 | Launch hardening | [./milestones/08-launch-hardening.md](./milestones/08-launch-hardening.md) | Lighthouse ≥ 95 + LGPD + CSP + Sentry | {{M08_STATUS}} |

Legenda de status: `pending` / `in-progress` / `in-review` / `done`.

## Ordem de execução sugerida

```
00 ─→ 01 ─→ 02 ─→ 03 ─→ 04 ─┐
                            ├─→ 08 (launch)
05 ─→ 06 ─→ 07 ─────────────┘
```

Adapte ao produto. Milestones podem rodar em paralelo se forem independentes em código (diferentes diretórios do app).

## Documentos complementares

- [BRIEF.md](./BRIEF.md) — produto, ICP, princípios
- [REFERENCES.md](./REFERENCES.md) — referências visuais
- [DESIGN_SYSTEM.md](./DESIGN_SYSTEM.md) — tokens, tipografia, geometria, do/don't
- [ARCHITECTURE.md](./ARCHITECTURE.md) (mesma pasta `docs/`) — stack, decisões, diagrama
- [WORKFLOW.md](./WORKFLOW.md) — regras de branch/PR/merge
- [BACKLOG.md](./BACKLOG.md) — features pós-V0
- [OPERATIONS/PERFORMANCE.md](./OPERATIONS/PERFORMANCE.md) — orçamentos perf + checklist (Fase 5)
- [OPERATIONS/SECURITY.md](./OPERATIONS/SECURITY.md) — threat model + controles (Fase 5)
- [CLAUDE.md](./CLAUDE.md) — convenções da IA

## Glossário

| {{PT_PRIMARY_LOCALE}} (UI) | EN (código) |
|---|---|
| {{TERM_1_PT}} | {{TERM_1_EN}} |
| {{TERM_2_PT}} | {{TERM_2_EN}} |
| {{TERM_3_PT}} | {{TERM_3_EN}} |
| Administrador | admin |
| Organização | organization (org) |
| Convite | invitation |
| Assento | seat |
| Concluído | completed |
| Em andamento | in_progress |
| Rascunho | draft |
| Publicado | published |
