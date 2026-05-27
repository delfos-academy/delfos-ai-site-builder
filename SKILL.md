---
name: delfos-ai-site-builder
description: Workflow determinístico para construir sites de produção (Next.js + Vercel + Neon + Tailwind + shadcn) com IA. Usar quando o usuário pedir para construir um site/app web do zero, criar um plano de implementação para um produto novo, gerar um design system a partir de referências, ou estruturar um repo seguindo o padrão Delfos. Cobre discovery → design system → arquitetura → plano mestre em milestones → execução em branches com testes → launch hardening (perf/security/SEO/LGPD).
---

# Delfos AI Site Builder

Skill para construir sites de produção com IA seguindo o playbook que a Delfos usa internamente. Stack-locked em Next.js 16 + Vercel + Neon + Drizzle + Tailwind v4 + shadcn/ui.

A skill é **determinística**: cada fase tem entradas, saídas e quality gates explícitos. O Claude não improvisa a ordem — segue o WF.

## Quando usar

- Usuário quer construir um site/web app **do zero** (não para refatorar um existente).
- Usuário pediu um "plano de implementação" para um produto novo.
- Usuário forneceu uma **referência visual** (link, screenshot, competitor) e pediu "faça parecido com isso".
- Você precisa estruturar um repo seguindo o padrão de documentação Delfos (PLAN + MILESTONES + DESIGN_SYSTEM + ARCHITECTURE).

**Quando NÃO usar:** refatoração de codebase existente, hotfix, dúvida pontual sobre uma feature já implementada, ou stacks fora de Next.js.

## Fluxo (ler na ordem)

| # | Fase | Documento da skill | Saídas no projeto-alvo |
|---|---|---|---|
| 0 | Discovery | [workflow/00-discovery.md](workflow/00-discovery.md) | `docs/BRIEF.md`, `docs/REFERENCES.md` |
| 0b | Capturar referência | [workflow/00b-capture-reference.md](workflow/00b-capture-reference.md) | `docs/references/<slug>/{full.png, page.html, styles.css, …}` |
| 1 | Design System | [workflow/01-design-system.md](workflow/01-design-system.md) | `docs/DESIGN_SYSTEM.md` + `app/globals.css` |
| 2 | Architecture | [workflow/02-architecture.md](workflow/02-architecture.md) | `docs/ARCHITECTURE.md`, **`CLAUDE.md` (raiz)**, `docs/operations/SECURITY.md` (v0), `docs/operations/PERFORMANCE.md` (v0), `docs/CODE_ORGANIZATION.md` |
| 3 | Master Plan | [workflow/03-master-plan.md](workflow/03-master-plan.md) | `docs/PLAN.md` + `docs/milestones/NN-*.md` + `docs/WORKFLOW.md` + `docs/BACKLOG.md` |
| 4 | Execute milestone (loop) | [workflow/04-execute-milestone.md](workflow/04-execute-milestone.md) | código + testes + PR (aplicando regras de `docs/operations/`) |
| 5 | Launch hardening | [workflow/05-launch-hardening.md](workflow/05-launch-hardening.md) | `docs/operations/` completados, SEO/LGPD/monitoring |
| — | Quality gates | [workflow/quality-gates.md](workflow/quality-gates.md) | aplicado em todo merge |
| — | Organização de código | [workflow/code-organization.md](workflow/code-organization.md) | regra transversal em toda Fase 4 |
| — | Otimização de tokens | [workflow/token-optimization.md](workflow/token-optimization.md) | heurísticas para contexto eficiente |
| — | Disciplina de commit e testes | [workflow/commit-discipline.md](workflow/commit-discipline.md) | Conventional Commits + testes verdes antes de cada commit |
| — | Layout do repo | [workflow/repo-layout.md](workflow/repo-layout.md) | whitelist da raiz + estrutura de `docs/` |
| — | Mapa de referência | [workflow/reference-map.md](workflow/reference-map.md) | quando cada documento é carregado em cada fase |
| — | Compatibilidade | [COMPATIBILITY.md](COMPATIBILITY.md) | como adaptar para Cursor/Copilot/Codex/Gemini/Aider |

## Princípios não-negociáveis

Estes vêm do `CLAUDE.md` da Delfos e ficam embutidos na skill:

1. **Funcional desde V0.** 5 features impecáveis > 15 meia-bocas.
2. **Aesthetic equals functional.** Qualidade visual é requisito de produto, não polimento.
3. **Comfort em sessões longas.** Tipografia legível, dark mode default, contraste cuidadoso.
4. **Tests desde o dia 1.** Vitest (unit) + Playwright (E2E) obrigatórios.
5. **Não DataCamp, não AI-default.** Sem gradientes, sem blur-glow, sem Inter, sem icon-chips. Ver [templates/DESIGN_SYSTEM.md.tpl](templates/DESIGN_SYSTEM.md.tpl) §7.
6. **Cada milestone fecha com PR + quality gate + aprovação do user.** Sem auto-merge.

## Como o Claude deve operar dentro da skill

- **Token-eficiente:** carrega apenas o milestone ativo, não o plano inteiro. PLAN.md é índice fino; o conteúdo vive em `MILESTONES/NN-*.md`.
- **Subagents para paralelismo:**
  - `Explore` para varredura de código existente
  - `general-purpose` para pesquisa web (referências, competitors)
  - Subagents customizados em `agents/` quando aplicável
- **Hooks PostToolUse** rodam `pnpm typecheck` + `pnpm lint` automaticamente após Edit/Write em `.ts/.tsx`. Ver [hooks/settings.json.example](hooks/settings.json.example).
- **Skills auxiliares** chamadas via tool `Skill`:
  - `ui-ux-pro-max` em todo trabalho visual significativo
  - `frontend-design` para gerar componentes distintos
  - `verify` antes de claim "está pronto" em UI
  - `security-review` antes de merge em milestone que toca auth/billing/dados sensíveis
  - `marketing-copywriter-1` para qualquer copy
- **Antes de implementar testes:** ler [prompts/tests-from-requirements.md](prompts/tests-from-requirements.md).

## Estrutura final no projeto-alvo

> **Raiz limpa.** Só `README.md`, `CLAUDE.md`, e configs obrigatórios. Tudo o resto vai pra subpastas. Regra completa em [workflow/repo-layout.md](workflow/repo-layout.md).

```
projeto/
├── README.md                       # Convenção GitHub
├── CLAUDE.md                       # Convenção Claude Code (carrega auto)
├── package.json, tsconfig.json, next.config.ts, proxy.ts, vercel.json,
│   eslint.config.mjs, .prettierrc, components.json, postcss.config.mjs,
│   drizzle.config.ts, vitest.config.ts, playwright.config.ts,
│   instrumentation.ts, instrumentation-client.ts, .env.example, .gitignore
├── docs/                           # Todos os docs do produto vivem aqui
│   ├── BRIEF.md                    # Output da Fase 0
│   ├── REFERENCES.md               # Output da Fase 0
│   ├── DESIGN_SYSTEM.md            # Output da Fase 1
│   ├── ARCHITECTURE.md             # Output da Fase 2
│   ├── CODE_ORGANIZATION.md        # Output da Fase 2
│   ├── PLAN.md                     # Output da Fase 3 (índice fino)
│   ├── WORKFLOW.md                 # Regras de branch/PR/merge
│   ├── BACKLOG.md                  # Features pós-V0
│   ├── milestones/
│   │   ├── 00-bootstrap.md
│   │   ├── 01-foundation.md
│   │   └── …
│   ├── operations/
│   │   ├── PERFORMANCE.md          # Fase 2 (v0) → incrementado na Fase 5
│   │   └── SECURITY.md             # Fase 2 (v0) → incrementado na Fase 5
│   ├── references/                 # Saídas da Fase 0b
│   │   └── <slug>/
│   ├── decisions/                  # ADRs grandes
│   ├── incidents/
│   └── postmortems/
├── app/, components/, lib/, tests/, public/
├── scripts/
│   └── capture-reference.mjs       # Copiado de templates/, Playwright headless
└── drizzle/                        # Migrations geradas
```

## Conteúdo da skill

- [README.md](README.md) — visão geral e como instalar
- [COMPATIBILITY.md](COMPATIBILITY.md) — como usar com Cursor, Copilot, Codex, Gemini, Aider
- [adapters/](adapters/) — arquivos de config prontos por ferramenta (cursor, copilot, codex, gemini, aider, continue)
- [workflow/](workflow/) — as 6 fases + quality gates
- [templates/](templates/) — arquivos `.tpl` que viram docs do projeto-alvo
- [checklists/](checklists/) — definition of done por etapa
- [agents/](agents/) — subagents customizados (design-extractor, milestone-planner, requirement-tester) — **preferir sobre prompts quando em Claude Code**
- [prompts/](prompts/) — sub-prompts reutilizáveis; fallback quando subagents não estão disponíveis (Cursor, Copilot, uso manual)
- [hooks/](hooks/) — configuração de hooks PostToolUse para o projeto-alvo
- [scripts/](scripts/) — scripts utilitários (capture-reference.mjs.tpl)
