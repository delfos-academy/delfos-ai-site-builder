# delfos-ai-site-builder

Skill para Claude Code que orquestra a construção de sites de produção seguindo o playbook interno da Delfos. Stack: **Next.js 16 + Vercel + Neon + Drizzle + Tailwind v4 + shadcn/ui**.

> **Propósito.** Dar ao Claude um WF determinístico (entradas, saídas, quality gates) para sair de uma referência visual + brief até um site funcional em produção, com testes, segurança, performance e conformidade LGPD desde o V0.

## Por que existe

Sites gerados por IA tipicamente saem com:

- "AI default look": gradientes, blur-glow, Inter, icon-chips coloridos, três colunas com ícone-título-parágrafo.
- Sem testes, sem CI, sem proteção em rota.
- Plano vago tipo "implementar a feature" que vira código sem requisitos verificáveis.
- Auth, billing e RBAC pensados como afterthought.

Esta skill força um caminho oposto: **discovery → design system → arquitetura → milestones com requisitos testáveis → branches isoladas → quality gates antes de merge**.

## Instalação

### Como plugin Claude Code (recomendado)

```bash
# (a partir do diretório onde queremos usar)
mkdir -p .claude/skills
git clone https://github.com/delfos-academy/delfos-ai-site-builder .claude/skills/delfos-ai-site-builder
```

A skill aparece automaticamente para o Claude na próxima sessão.

### Como skill global do usuário

```powershell
git clone https://github.com/delfos-academy/delfos-ai-site-builder $HOME\.claude\skills\delfos-ai-site-builder
```

## Uso típico

Em uma sessão Claude Code dentro do diretório vazio do projeto-alvo:

```
> Quero construir um site usando a skill delfos-ai-site-builder. Aqui está minha referência: https://exemplo.com. E o brief: um SaaS para advogados criminalistas gerenciarem petições.
```

O Claude vai:

1. Ler `SKILL.md` e abrir o workflow.
2. Fase 0 — extrair brief + perguntar gaps + capturar referências em `docs/BRIEF.md` e `docs/REFERENCES.md`.
3. Fase 1 — gerar `docs/DESIGN_SYSTEM.md` e `app/globals.css` (chamando `ui-ux-pro-max` quando útil).
4. Fase 2 — `docs/ARCHITECTURE.md` com stack locked + `CLAUDE.md` (raiz) + `docs/operations/` v0.
5. Fase 3 — `docs/PLAN.md` + 6 a 10 `docs/milestones/NN-*.md`.
6. Fase 4 — cria branch, escreve testes a partir dos requisitos, implementa, roda quality gate, abre PR.
7. Você revisa, aprova, merge. Próximo milestone.
8. Fase 5 — hardening final (Lighthouse, CSP, rate limit, SEO, LGPD).

## Estrutura do repo

```
delfos-ai-site-builder/
├── SKILL.md                          # Entry point (frontmatter Anthropic skill)
├── README.md                         # Este arquivo
├── COMPATIBILITY.md                  # Guia para Cursor/Copilot/Codex/Gemini/Aider
├── adapters/                         # Arquivos de config prontos por ferramenta
│   ├── cursor/                       # .cursor/rules/
│   ├── copilot/                      # .github/copilot-instructions.md
│   ├── codex/                        # AGENTS.md
│   ├── gemini/                       # .idx/airules.md
│   ├── aider/                        # CONVENTIONS.md + .aider.conf.yml
│   └── continue/                     # .continue/rules/
├── workflow/                         # As 6 fases + quality gates
├── templates/                        # Arquivos .tpl copiados pro projeto-alvo
│   └── OPERATIONS/                   # PERFORMANCE.md.tpl, SECURITY.md.tpl
├── checklists/                       # Definition of done por etapa
├── prompts/                          # Sub-prompts reutilizáveis (fallback sem subagents)
├── agents/                           # Subagents customizados (preferir sobre prompts)
├── hooks/                            # settings.json.example com PostToolUse
└── scripts/                          # Scripts utilitários (.tpl copiados pro projeto-alvo)
```

## Convenções dos templates

Arquivos com sufixo `.tpl` contêm placeholders entre `{{chaves}}` que o Claude substitui ao copiar para o projeto-alvo. Exemplos:

- `{{PROJECT_NAME}}` → nome do produto (ex: "Delfos Academy")
- `{{PROJECT_SLUG}}` → slug em kebab (ex: "delfos-academy")
- `{{PT_PRIMARY_LOCALE}}` → `pt-BR` por default
- `{{BRAND_PRIMARY_HSL}}` → cor primária em HSL (ex: `141 73% 48%`)

## Compatibilidade

- Claude Code CLI ≥ 1.0
- Node.js ≥ 20 no projeto-alvo
- Stack-locked: Next.js 16, Tailwind v4, shadcn/ui, Drizzle, Neon Postgres, Resend, Vercel

Outras stacks: ver branches `feat/stack-*` (não disponíveis ainda).

## Status

V0. Construído a partir do playbook da Delfos Academy (mai/2026). Primeiro dogfooding será o próprio Delfos.
