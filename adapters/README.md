# Adapters

Arquivos de configuração prontos para cada ferramenta de IA. Cada adapter é um
arquivo thin que diz ao tool "leia estas regras e siga este workflow" — o conteúdo
real vive em `workflow/`, `templates/` e `checklists/`.

## Instalação padrão (não-Claude Code)

```bash
# Na raiz do projeto-alvo, instalar a skill em .skill/
git clone https://github.com/delfos-academy/delfos-ai-site-builder .skill

# Adicionar .skill/ ao .gitignore se não quiser versionar
echo ".skill/" >> .gitignore
```

Depois copiar o adapter da sua ferramenta:

| Ferramenta | Comando |
|---|---|
| **Cursor** | `cp .skill/adapters/cursor/delfos-builder.mdc .cursor/rules/delfos-builder.mdc` |
| **GitHub Copilot** | `cp .skill/adapters/copilot/copilot-instructions.md .github/copilot-instructions.md` |
| **Codex CLI** | `cp .skill/adapters/codex/AGENTS.md AGENTS.md` |
| **Gemini (Firebase Studio)** | `mkdir -p .idx && cp .skill/adapters/gemini/airules.md .idx/airules.md` |
| **Aider** | `cp .skill/adapters/aider/CONVENTIONS.md CONVENTIONS.md` |
| **Continue.dev** | `mkdir -p .continue/rules && cp .skill/adapters/continue/site-builder.md .continue/rules/delfos-builder.md` |

## Claude Code

Instalação diferente — skill vai em `.claude/skills/`, não em `.skill/`:

```bash
# Projeto (compartilhado com a equipe)
mkdir -p .claude/skills
git clone https://github.com/delfos-academy/delfos-ai-site-builder .claude/skills/delfos-ai-site-builder

# Global (só sua máquina)
git clone https://github.com/delfos-academy/delfos-ai-site-builder $HOME\.claude\skills\delfos-ai-site-builder
```

Claude Code lê `SKILL.md` na raiz — sem adapter adicional.

## Mantendo atualizado

Quando o workflow evoluir:

```bash
cd .skill && git pull
# Re-copiar o adapter se o arquivo de adapter mudou
cp .skill/adapters/<tool>/... <destino>
```

Os arquivos de `workflow/` são referenciados por path — se o adapter usa `@.skill/workflow/...`,
a atualização do workflow é automática após `git pull`.

## O que cada adapter faz

- **Não duplica** as regras — só aponta para os arquivos em `.skill/workflow/`
- Fornece o **resumo essencial** das convenções para tools que não suportam referências a arquivo
- Configura o **contexto inicial** para cada sessão de IA
