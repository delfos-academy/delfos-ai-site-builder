# Subagents

Definições de subagents Claude Code que a skill `delfos-ai-site-builder` orquestra.

## Como subagents são carregados

Claude Code carrega arquivos `.md` desta pasta como definições de subagent quando este diretório está em uma das paths configuradas. Para a skill:

1. **Como plugin** — automático ao instalar.
2. **Manualmente** — copiar para `.claude/agents/` no projeto-alvo:
   ```bash
   cp <skill_path>/agents/*.md .claude/agents/
   ```

## Subagents disponíveis

| Nome | Quando usar | Skill phase |
|---|---|---|
| `design-extractor` | Extrair design tokens de uma referência visual | Fase 1 |
| `milestone-planner` | Decompor brief + arch em milestones | Fase 3 |
| `requirement-tester` | Converter done criteria em testes Vitest/Playwright antes da impl | Fase 4 |

## Como o agente principal os invoca

Usar a tool `Agent` com `subagent_type` igual ao nome do arquivo (sem `.md`).

```
Agent({
  subagent_type: "design-extractor",
  prompt: "Extrai design system desta referência: <URL>. Brief: <brief one-liner>.",
  description: "Design extraction from <URL>"
})
```

## Princípios de uso

- **Contexto isolado** — o subagent não vê a conversa principal. Sempre passar contexto completo no prompt.
- **Saída estruturada** — todos retornam formato bem definido (YAML para design, markdown para plan, código para tests).
- **Não substitui main agent** — subagents fazem tarefas focadas, depois main agent integra a saída.
- **Token-eficiente** — usar para evitar inflar contexto principal com pesquisa/análise grande.

## Criando subagents novos

Frontmatter mínimo:

```yaml
---
name: <slug>
description: <quando usar, em uma linha — vai pro tool selector>
tools: <lista de tools, default: todas>
---
```

Body: instruções completas, exemplos de output, validações antes de retornar.

Ver os 3 existentes como exemplo.
