# Compatibilidade com outros assistentes de código

> A skill foi desenhada para **Claude Code**. Esta página explica o que é portável (markdown puro, regras objetivas) e o que é Claude-específico (frontmatter, subagents, hooks).

## Funciona "como skill" em quê?

| Ferramenta | Funciona como skill? | O que aproveita |
|---|---|---|
| **Claude Code** | ✅ Nativo | Tudo (SKILL.md, agents, hooks, prompts) |
| **Cursor** | ⚠️ Parcial via rules | Templates, checklists, workflow .md |
| **GitHub Copilot** | ⚠️ Parcial via copilot-instructions | Templates, checklists, workflow .md |
| **Codex CLI (OpenAI)** | ⚠️ Parcial via AGENTS.md | Templates, checklists, workflow .md |
| **Gemini Code Assist** | ⚠️ Parcial via system prompt | Templates, checklists |
| **Aider** | ⚠️ Parcial via CONVENTIONS | Templates, checklists |
| **Continue.dev** | ⚠️ Parcial via `.continue/rules/` | Templates, checklists |

> **Claude-específico:** SKILL.md frontmatter, `agents/*.md` (subagents), `hooks/settings.json`, `Skill` tool, `Agent` tool.
> **Portável:** todo o `workflow/`, `templates/`, `checklists/`, `prompts/`, `scripts/`. Markdown puro com instruções acionáveis.

## Como adaptar para cada ferramenta

### Claude Code (recomendado)

Instalar como descrito em [README.md](README.md). Tudo funciona out-of-the-box.

```bash
mkdir -p .claude/skills
git clone <repo> .claude/skills/delfos-ai-site-builder
```

### Cursor

1. Copiar os templates e checklists para o projeto-alvo (mesmo path).
2. Criar `.cursor/rules/delfos-builder.mdc` apontando para os documentos do workflow:

```mdc
---
description: Site builder com padrão Delfos
globs: ["**/*.ts", "**/*.tsx", "**/*.md"]
alwaysApply: false
---

Siga o workflow em workflow/04-execute-milestone.md ao implementar.
Respeite os limites de tamanho de workflow/code-organization.md.
Aplique a checklist de checklists/code-organization.md em todo diff.

@workflow/04-execute-milestone.md
@workflow/code-organization.md
@workflow/token-optimization.md
@checklists/milestone-done.md
@CLAUDE.md
```

**O que NÃO funciona em Cursor:**
- Subagents (Cursor tem Agent mode mas não definições reutilizáveis em `.md`)
- Hooks PostToolUse (Cursor não tem)
- Tool `Skill` (Cursor não tem skill system)

**Workarounds:**
- Subagents viram instruções inline ("quando precisar extrair design, siga prompts/extract-design-from-reference.md")
- Hooks viram regras manuais ("após editar .ts/.tsx, rodar `pnpm typecheck`")

### GitHub Copilot

1. Copiar templates e checklists.
2. Criar `.github/copilot-instructions.md` na raiz com sumário dos princípios + links:

```md
# Project conventions

Stack: Next.js 16 + Vercel + Neon + Drizzle + Tailwind v4 + shadcn/ui.

Convenções principais:
- TypeScript strict, `noUncheckedIndexedAccess: true`
- Zod em toda entrada externa
- RSC default; `'use client'` só quando necessário
- Limites: componente .tsx ≤ 250 linhas, action ≤ 400, lib ≤ 350
- JSDoc obrigatório em superfícies públicas (exports de index.ts, server actions)
- Imports ordenados: side-effect → node → external → @/ → relativo → type

Ver workflow/code-organization.md e CLAUDE.md.

Antes de fazer commit:
- `pnpm typecheck` zero erros
- `pnpm lint` zero warnings
- `pnpm test:unit` 100% green
```

**O que NÃO funciona:**
- Sub-prompts reutilizáveis (Copilot não chama outros prompts)
- Hooks
- Workflow multi-fase orquestrado (Copilot é completions, não agente)

**Aproveitável:** convenções de código, templates, naming.

### Codex CLI (OpenAI)

1. Copiar templates e checklists.
2. Criar `AGENTS.md` na raiz (Codex lê isso automaticamente):

```md
# {{PROJECT_NAME}}

Siga o workflow:
- Discovery → BRIEF.md, REFERENCES.md
- Design System → DESIGN_SYSTEM.md + app/globals.css
- Architecture → ARCHITECTURE.md
- Master Plan → PLAN.md + MILESTONES/
- Execute → branch + tests + impl + PR
- Hardening → OPERATIONS/

Regras:
- workflow/code-organization.md (tamanhos, public API, JSDoc)
- workflow/token-optimization.md
- checklists/milestone-done.md antes de PR
- checklists/code-organization.md em todo diff

Comandos:
- pnpm typecheck / lint / test:unit / test:e2e / build / db:push
```

**O que NÃO funciona:**
- Subagents nominais
- Hooks Claude-style
- Tool `Skill`

**Aproveitável:** workflow, templates, regras.

### Gemini Code Assist

Sem mecanismo equivalente a SKILL.md. Opções:

1. **Project IDX (Firebase)**: `.idx/airules.md` na raiz com sumário dos princípios.
2. **VS Code extension**: sem rules persistentes — colar sumário das regras no chat por sessão.
3. **API direto**: passar `workflow/04-execute-milestone.md` + `CLAUDE.md` como system instructions.

### Aider

1. Copiar templates e checklists.
2. Criar `CONVENTIONS.md` na raiz com sumário das regras.
3. Em `.aider.conf.yml`:

```yaml
read:
  - CLAUDE.md
  - CONVENTIONS.md
  - workflow/code-organization.md
auto-commits: false   # mantém controle de commits no humano
test-cmd: "pnpm test:unit && pnpm typecheck && pnpm lint"
```

Aider tem `--test` que roda comandos pós-edit — equivalente parcial aos hooks.

### Continue.dev

1. Copiar templates e checklists.
2. Em `.continue/rules/site-builder.md`:

```md
---
name: Delfos site builder
description: Workflow para construir sites no padrão Delfos
---

Siga workflow/04-execute-milestone.md.
Respeite workflow/code-organization.md.
```

Continue suporta múltiplos modelos (pode usar Claude + GPT-4 + Gemini no mesmo workspace), e cada um lê as rules — então a skill efetivamente funciona em **qualquer modelo** dentro do Continue, mesmo os que não são Claude.

## O conteúdo que sempre funciona

Independente da ferramenta, **estes documentos são markdown puro acionável** e podem ser referenciados/colados em qualquer prompt:

- `workflow/00-discovery.md` → como descobrir produto
- `workflow/01-design-system.md` → como criar design system
- `workflow/02-architecture.md` → como decidir arquitetura
- `workflow/03-master-plan.md` → como decompor em milestones
- `workflow/04-execute-milestone.md` → como executar milestone
- `workflow/05-launch-hardening.md` → como fazer hardening
- `workflow/quality-gates.md` → gates objetivos
- `workflow/code-organization.md` → regras de código
- `workflow/token-optimization.md` → heurísticas de contexto
- `templates/*.tpl` → estruturas determinísticas
- `checklists/*.md` → listas verificáveis
- `prompts/*.md` → sub-prompts reutilizáveis
- `scripts/capture-reference.mjs.tpl` → Node puro, roda em qualquer ambiente

## Quando vale escolher Claude Code vs alternativas

A skill é mais poderosa em Claude Code porque:

1. **Subagents isolam contexto** — `design-extractor` lê 5 arquivos de referência sem inflar a sessão principal. Outras ferramentas: tudo vai pro main context.
2. **Hooks automatizam quality gates** — typecheck/lint rodam sem o agente "lembrar". Outras ferramentas: agente esquece.
3. **Tool `Skill`** chama skills auxiliares (`ui-ux-pro-max`, `verify`, `security-review`) dentro da execução. Outras ferramentas: instruções viram texto solto, mais variância.
4. **Plan mode** — Claude pode propor antes de mudar.

Se você é flexível em ferramenta: **Claude Code maximiza ROI desta skill**. Se já usa outra: aproveita ~70% do valor copiando os documentos markdown.

## Filosofia portável (independente de ferramenta)

Mesmo sem nenhuma das integrações específicas, **a estrutura de pensamento** resolve problemas que toda IA tem:

- **Discovery antes de design.** Toda ferramenta beneficia de brief escrito.
- **Design system antes de features.** Toda ferramenta beneficia de tokens definidos.
- **Plano em milestones com critério testável.** Toda ferramenta beneficia.
- **Tests antes de implementar.** Toda ferramenta beneficia.
- **Limites de tamanho de arquivo.** Toda ferramenta beneficia.
- **Public API por feature.** Toda ferramenta beneficia.
- **JSDoc em superfícies públicas.** Toda ferramenta beneficia.

Skill ≠ apenas integração técnica. É **playbook** — funciona até em papel.
