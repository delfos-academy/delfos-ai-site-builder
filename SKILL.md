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
| 0 | Discovery | [workflow/00-discovery.md](workflow/00-discovery.md) | `BRIEF.md`, `REFERENCES.md` |
| 0b | Capturar referência | [workflow/00b-capture-reference.md](workflow/00b-capture-reference.md) | `references/<slug>/{full.png, page.html, styles.css, …}` |
| 1 | Design System | [workflow/01-design-system.md](workflow/01-design-system.md) | `DESIGN_SYSTEM.md` + `app/globals.css` |
| 2 | Architecture | [workflow/02-architecture.md](workflow/02-architecture.md) | `ARCHITECTURE.md` |
| 3 | Master Plan | [workflow/03-master-plan.md](workflow/03-master-plan.md) | `PLAN.md` + `MILESTONES/NN-*.md` |
| 4 | Execute milestone (loop) | [workflow/04-execute-milestone.md](workflow/04-execute-milestone.md) | código + testes + PR |
| 5 | Launch hardening | [workflow/05-launch-hardening.md](workflow/05-launch-hardening.md) | `OPERATIONS/PERFORMANCE.md`, `OPERATIONS/SECURITY.md`, SEO/LGPD |
| — | Quality gates | [workflow/quality-gates.md](workflow/quality-gates.md) | aplicado em todo merge |
| — | Organização de código | [workflow/code-organization.md](workflow/code-organization.md) | regra transversal em toda Fase 4 |
| — | Otimização de tokens | [workflow/token-optimization.md](workflow/token-optimization.md) | heurísticas para contexto eficiente |
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

Após rodar a skill completa, o projeto-alvo terá:

```
projeto/
├── CLAUDE.md                  # Convenções, copiado de templates/CLAUDE.md.tpl
├── BRIEF.md                   # Output da Fase 0
├── REFERENCES.md              # Output da Fase 0
├── DESIGN_SYSTEM.md           # Output da Fase 1
├── ARCHITECTURE.md            # Output da Fase 2
├── PLAN.md                    # Índice mestre (Fase 3)
├── WORKFLOW.md                # Regras de branch/PR/merge
├── CODE_ORGANIZATION.md       # Estrutura de pastas, limites, naming, JSDoc
├── BACKLOG.md                 # Features pós-V0
├── MILESTONES/
│   ├── 00-bootstrap.md
│   ├── 01-foundation.md
│   └── …
├── OPERATIONS/
│   ├── PERFORMANCE.md         # Fase 5
│   └── SECURITY.md            # Fase 5
├── references/                # Saídas da Fase 0b (capturas de referência)
│   └── <slug>/
├── scripts/
│   └── capture-reference.mjs  # Copiado de templates/, roda Playwright headless
└── (código do app)
```

## Conteúdo da skill

- [README.md](README.md) — visão geral e como instalar
- [workflow/](workflow/) — as 6 fases + quality gates
- [templates/](templates/) — arquivos `.tpl` que viram docs do projeto-alvo
- [checklists/](checklists/) — definition of done por etapa
- [prompts/](prompts/) — sub-prompts reutilizáveis (extract design, decompose milestone, tests from requirements, pre-merge review)
- [hooks/](hooks/) — configuração de hooks PostToolUse para o projeto-alvo
- [agents/](agents/) — subagents customizados (design-extractor, milestone-planner, requirement-tester)
