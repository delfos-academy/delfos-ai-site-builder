# Milestone {{NN}} — {{MILESTONE_NAME}}

**Objetivo.** {{MILESTONE_GOAL_ONE_LINE}}

**Critério de pronto (testável — vira teste antes de implementar).**
- [ ] {{DONE_REQ_1}}
- [ ] {{DONE_REQ_2}}
- [ ] {{DONE_REQ_3}}

**Dependências.** {{DEPENDS_ON}} (ex: `00-bootstrap` mergeado, ou "nenhuma")

**Branch.** `feat/M{{NN}}-{{SLUG}}`

---

## Pré-requisitos do user (se houver)

- [ ] {{USER_PREREQ_1}}
- [ ] {{USER_PREREQ_2}}

## Tasks

### Setup

- [ ] {{SETUP_TASK_1}}
- [ ] {{SETUP_TASK_2}}

### {{SECTION_2_NAME}}

- [ ] {{S2_TASK_1}}
- [ ] {{S2_TASK_2}}
- [ ] {{S2_TASK_3}}

### {{SECTION_3_NAME}}

- [ ] {{S3_TASK_1}}
- [ ] {{S3_TASK_2}}

### UI/UX

- [ ] {{UI_TASK_1}}
- [ ] {{UI_TASK_2}}
- [ ] Snapshot light + dark + 375px + 1440px
- [ ] Skill `ui-ux-pro-max` se for tela significativa
- [ ] Skill `verify` antes do PR

### Validação, segurança e performance

> Antes de implementar este milestone, **leia as seções relevantes**:
> - `docs/operations/SECURITY.md` — regras de auth, RBAC, rate limit, headers, input validation, LGPD que aplicam a este milestone
> - `docs/operations/PERFORMANCE.md` — budget de bundle, rendering strategy, regras desde V0
>
> Estes documentos foram criados na Fase 2 (Architecture) com versão inicial. **Toda regra listada lá deve ser aplicada no código deste milestone**, não deixar pra Fase 5.

- [ ] Zod em toda entrada externa nova
- [ ] `import 'server-only'` em módulos com DB/secrets
- [ ] Regras aplicáveis de `docs/operations/SECURITY.md` aplicadas (auth pattern, RBAC, rate limit, headers se mudou next.config)
- [ ] Regras aplicáveis de `docs/operations/PERFORMANCE.md` aplicadas (next/image, RSC default, bundle budget respeitado)
- [ ] Skill `security-review` se tocou em auth/billing/dados sensíveis

## Testes obrigatórios

> Escrever **antes** de implementar (TDD-leve). Devem falhar inicialmente.

- [ ] Unit: {{UNIT_TEST_1}}
- [ ] Unit: {{UNIT_TEST_2}}
- [ ] E2E: {{E2E_FLOW_1}} (cobrindo critério de pronto)
- [ ] Schema/Zod: validação de {{SCHEMA_TEST}}
- [ ] Failure mode: {{FAILURE_MODE_TEST}} (ex: ação sem permissão → erro)

## Decisões registradas durante a execução

> ADR-lights inline. Cada decisão não-default que apareceu durante este milestone.

### D-MNN-001 — {{DECISION_TITLE}}
**Decisão:** {{DECISION_OUTCOME}}
**Motivo:** {{DECISION_REASON}}
**Reversível:** {{REVERSIBLE}}

## Quality gate antes do PR

Ver [quality-gates.md da skill](https://github.com/delfos-academy/delfos-ai-site-builder/blob/main/workflow/quality-gates.md) ou [checklists/milestone-done.md](https://github.com/delfos-academy/delfos-ai-site-builder/blob/main/checklists/milestone-done.md).

```bash
pnpm typecheck
pnpm lint
pnpm test:unit
pnpm test:e2e
pnpm build
```

## Status

- [ ] Branch criada
- [ ] Testes do critério de pronto escritos e falhando (red)
- [ ] Implementação completa
- [ ] Testes do critério de pronto passando (green)
- [ ] Quality gate local passou (typecheck + lint + tests + build)
- [ ] Screenshots / snapshots anexados se tocou em UI
- [ ] Skill `security-review` rodada (se aplicável)
- [ ] PR aberto: {{PR_URL}}
- [ ] Aprovado pelo user
- [ ] Mergeado em main
