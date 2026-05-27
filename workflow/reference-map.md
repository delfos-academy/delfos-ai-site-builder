# Reference map — quando cada documento é carregado

> Visão consolidada de "o que o Claude lê em cada momento". Útil para entender o custo de contexto e para garantir que regras críticas (segurança, performance, design) **estão em mãos quando importam**, não só no final.

## Regra de ouro

**Nenhuma decisão estrutural é tomada sem o documento que a governa estar carregado no contexto.**

- Decisão de design? → `DESIGN_SYSTEM.md` está carregado.
- Decisão de auth/rate limit? → `OPERATIONS/SECURITY.md` está carregado (mesmo a versão inicial da Fase 2).
- Decisão de query/rendering? → `OPERATIONS/PERFORMANCE.md` está carregado.

Por isso os docs OPERATIONS são **criados na Fase 2**, não na Fase 5.

## Quando cada documento é criado vs lido

| Documento | Criado em | Lido a partir de | Atualizado em |
|---|---|---|---|
| `docs/BRIEF.md` | Fase 0 | Todas as fases seguintes (referência de produto) | Quando produto pivota |
| `docs/REFERENCES.md` | Fase 0 | Fase 1 (design extraction) | Quando adiciona referência |
| `docs/references/<slug>/` | Fase 0b | Fase 1 (subagent design-extractor) | Quando adiciona referência |
| `docs/DESIGN_SYSTEM.md` | Fase 1 | Toda Fase 4 que toca UI | Mudança visual significativa (raro) |
| `docs/ARCHITECTURE.md` | Fase 2 | Toda Fase 4 que toca infra/schema/auth | Quando decisão estrutural muda |
| `CLAUDE.md` (raiz, exceção) | Fase 2 | **Toda sessão Claude (automático)** | Quando convenção muda |
| `docs/operations/SECURITY.md` | **Fase 2 (versão inicial)** | **Toda Fase 4 que toca superfície relevante** | Incrementalmente na Fase 4, completado na Fase 5 |
| `docs/operations/PERFORMANCE.md` | **Fase 2 (versão inicial)** | **Toda Fase 4 que cria rota/feature** | Audits adicionados na Fase 4, completado na Fase 5 |
| `docs/PLAN.md` | Fase 3 | Toda Fase 4 (mas só linha do milestone ativo) | Quando milestone fecha (`status: done`) |
| `docs/milestones/NN-*.md` | Fase 3 | **Só o milestone ativo na Fase 4** | Durante a execução do milestone |
| `docs/WORKFLOW.md` | Fase 3 | Quando precisa lembrar regras de branch/PR | Raro |
| `docs/CODE_ORGANIZATION.md` | Fase 2-3 (instanciado) | Toda Fase 4 (mais a regra geral da skill) | Quando convenção muda |
| `docs/BACKLOG.md` | Fase 3 (vazio) | Quando aparece "boa ideia, mas depois" | Continuamente |
| Páginas legais (`/privacy`, `/terms`) | Fase 5 | — | LGPD update / mudança de produto |

## Contexto carregado por fase (típico)

### Sessão de Fase 0 (Discovery)
- `workflow/00-discovery.md` (da skill)
- `templates/BRIEF.md.tpl`, `templates/REFERENCES.md.tpl`
- Mensagem do user com brief + referências

**Tamanho:** ~5k tokens.

### Sessão de Fase 1 (Design System)
- `workflow/01-design-system.md`, `workflow/00b-capture-reference.md`
- `BRIEF.md`, `REFERENCES.md`, `references/<slug>/` (delegado ao subagent)
- `templates/DESIGN_SYSTEM.md.tpl`
- (subagent) `agents/design-extractor.md`, `prompts/extract-design-from-reference.md`

**Tamanho:** ~10k tokens main + isolado no subagent.

### Sessão de Fase 2 (Architecture)
- `workflow/02-architecture.md`
- `BRIEF.md`, `DESIGN_SYSTEM.md`
- `templates/ARCHITECTURE.md.tpl`, `templates/CLAUDE.md.tpl`
- `templates/OPERATIONS/SECURITY.md.tpl`, `templates/OPERATIONS/PERFORMANCE.md.tpl`

**Tamanho:** ~15k tokens.

### Sessão de Fase 3 (Master Plan)
- `workflow/03-master-plan.md`
- `BRIEF.md`, `ARCHITECTURE.md`, `DESIGN_SYSTEM.md`
- `templates/PLAN.md.tpl`, `templates/MILESTONE.md.tpl`, `templates/WORKFLOW.md.tpl`
- (subagent) `agents/milestone-planner.md`

**Tamanho:** ~12k tokens main.

### Sessão de Fase 4 (Execute milestone NN)
- **Automático em toda sessão:** `CLAUDE.md` (~150-200 linhas)
- `MILESTONES/NN-*.md` (só o ativo, ~200 linhas)
- Seções relevantes de `OPERATIONS/SECURITY.md` e `OPERATIONS/PERFORMANCE.md` (direcionado, não inteiro)
- `DESIGN_SYSTEM.md` se mexe em UI
- `ARCHITECTURE.md` se mexe em schema/infra
- `workflow/04`, `code-organization`, `commit-discipline`, `token-optimization` (via skill)

**Tamanho:** ~20-30k tokens, dependendo do milestone.

### Sessão de Fase 5 (Launch hardening)
- `workflow/05-launch-hardening.md`
- `OPERATIONS/SECURITY.md` (completo agora — incrementa o que estava lá)
- `OPERATIONS/PERFORMANCE.md` (completo agora)
- `checklists/launch-ready.md`, `checklists/security-review.md`

**Tamanho:** ~25k tokens.

## Por que adiantar OPERATIONS para a Fase 2 importa

Cenário ANTES da correção:

1. Fase 4 / Milestone 0 (Bootstrap): Claude implementa auth.
2. Sem `OPERATIONS/SECURITY.md` carregado, ele usa o que está em `CLAUDE.md`: "Zod em entrada, requireUser, sessão httpOnly".
3. Implementa com bcrypt (não Argon2id), token sem hash, rate limit `null`.
4. Fase 5: `OPERATIONS/SECURITY.md` é criado e lista as regras corretas.
5. **Refatoração**: trocar hash, adicionar hash de token, criar rate limit. 2 dias de trabalho, regressões.

Cenário DEPOIS da correção:

1. Fase 2: `OPERATIONS/SECURITY.md` versão inicial é criado com auth pattern (Argon2id), token SHA-256, rate limit defaults.
2. Fase 4 / Milestone 0: Claude lê seção `§Auth & Session` e `§Rate limiting`. Implementa correto na primeira vez.
3. Fase 5: documento é incrementado com threat model completo e audits — não refatora código.

A diferença é a **disponibilidade da regra no momento da decisão**, não a regra em si.

## Princípios derivados

- **Documento que governa decisão crítica nasce na fase que precede a primeira decisão**, não na fase que finaliza.
- **`CLAUDE.md` referencia OPERATIONS/** para o Claude saber que existe — mas não inclui o conteúdo (carregamento direcionado).
- **Cada MILESTONE.md.tpl referencia `OPERATIONS/`** na seção "Validação, segurança e performance" para forçar leitura direcionada antes de implementar.
- **Subagents recebem o documento relevante no prompt**, isoladamente — não carrega no main.

## Quando carregar OPERATIONS no contexto

| Tipo de mudança | Carregar de OPERATIONS/SECURITY.md | Carregar de OPERATIONS/PERFORMANCE.md |
|---|---|---|
| Auth (signup/login/reset/verify) | §Auth & Session, §Rate limiting, §Input validation | — |
| RBAC novo / role / permission | §Authorization (RBAC), §Audit log | — |
| Form público que dispara email | §Bot & abuse prevention, §Rate limiting | — |
| Webhook (Stripe etc) | §Webhooks, §Secrets | — |
| Schema com PII novo | §Data protection (LGPD), §Data inventory | — |
| File upload | §Input validation, §Vendor security | — |
| `next.config.ts` (headers/CSP) | §Headers | — |
| Nova rota / página | — | §Rendering strategy, §Bundle JS |
| Imagem nova | — | §Assets (next/image) |
| Lib dependency nova | — | §JavaScript (bundle budget) |
| DB query nova | — | §Database (indexes, N+1) |
| Component pesado (editor, chart) | — | §Lazy load |

## Custo

Adicionar OPERATIONS desde Fase 2 custa: 2 docs criados antes (Fase 2 fica ~20% mais longa). Economiza: refactor pesado de auth/perf na Fase 5 (~3-5 dias em projeto V0).

Trade-off vale.
