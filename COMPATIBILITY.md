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

## Como usar os adapters

A pasta [`adapters/`](adapters/) contém arquivos de configuração prontos para cada ferramenta.
**Não é mais necessário criar esses arquivos na mão** — copie o adapter correspondente.

### Instalação padrão (todas as ferramentas não-Claude)

```bash
# 1. Na raiz do projeto-alvo, instalar a skill em .skill/
git clone https://github.com/delfos-academy/delfos-ai-site-builder .skill
echo ".skill/" >> .gitignore   # opcional: não versionar

# 2. Copiar o adapter da sua ferramenta
```

### Claude Code (recomendado)

```bash
# Projeto (compartilhado com a equipe)
mkdir -p .claude/skills
git clone https://github.com/delfos-academy/delfos-ai-site-builder .claude/skills/delfos-ai-site-builder

# Ou global (só sua máquina)
git clone https://github.com/delfos-academy/delfos-ai-site-builder $HOME\.claude\skills\delfos-ai-site-builder
```

Tudo funciona out-of-the-box — Claude Code lê `SKILL.md` na raiz automaticamente.

### Cursor

```bash
mkdir -p .cursor/rules
cp .skill/adapters/cursor/delfos-builder.mdc .cursor/rules/delfos-builder.mdc
```

Arquivo: [`adapters/cursor/delfos-builder.mdc`](adapters/cursor/delfos-builder.mdc)

**O que NÃO funciona em Cursor:** subagents, hooks PostToolUse, tool `Skill`.
**Workaround subagents:** usar os sub-prompts em `.skill/prompts/` (referenciados no adapter).

### GitHub Copilot

```bash
mkdir -p .github
cp .skill/adapters/copilot/copilot-instructions.md .github/copilot-instructions.md
```

Arquivo: [`adapters/copilot/copilot-instructions.md`](adapters/copilot/copilot-instructions.md)

**O que NÃO funciona:** sub-prompts encadeados, hooks, workflow multi-fase orquestrado.
**Aproveitável:** convenções de código, templates, naming, quality gate.

### Codex CLI (OpenAI)

```bash
cp .skill/adapters/codex/AGENTS.md AGENTS.md
```

Arquivo: [`adapters/codex/AGENTS.md`](adapters/codex/AGENTS.md)

### Gemini (Firebase Studio / Project IDX)

```bash
mkdir -p .idx
cp .skill/adapters/gemini/airules.md .idx/airules.md
```

Arquivo: [`adapters/gemini/airules.md`](adapters/gemini/airules.md)

**VS Code extension:** sem rules persistentes — cole o conteúdo do adapter no primeiro prompt da sessão, ou instrua diretamente: "Siga `.skill/workflow/04-execute-milestone.md`".

### Aider

```bash
cp .skill/adapters/aider/CONVENTIONS.md CONVENTIONS.md
cp .skill/adapters/aider/.aider.conf.yml .aider.conf.yml   # ajustar se necessário
```

Arquivos: [`adapters/aider/`](adapters/aider/)

Aider tem `--test` que roda comandos pós-edit — equivalente parcial aos hooks do Claude Code.

### Continue.dev

```bash
mkdir -p .continue/rules
cp .skill/adapters/continue/site-builder.md .continue/rules/delfos-builder.md
```

Arquivo: [`adapters/continue/site-builder.md`](adapters/continue/site-builder.md)

Continue suporta múltiplos modelos (Claude + GPT-4 + Gemini no mesmo workspace) — o adapter funciona com qualquer um deles.

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
