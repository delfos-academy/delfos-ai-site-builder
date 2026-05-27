# Hooks

Configuração de hooks Claude Code para o projeto-alvo. Hooks rodam comandos automaticamente em eventos (PostToolUse, PreToolUse, Stop, etc), antes/depois de tool calls.

## Por que usar

Sem hooks, o Claude **precisa lembrar** de rodar `pnpm typecheck` e `pnpm lint` após editar. Com hooks, o harness força a execução — pega regressões mais cedo.

## Instalação no projeto-alvo

1. Copie `settings.json.example` para `.claude/settings.json` no projeto-alvo (ou `.claude/settings.local.json` se quiser local apenas).
2. Ajuste comandos se o package manager for diferente (`npm`, `yarn`, `bun`).

```bash
mkdir -p .claude
cp <skill_path>/hooks/settings.json.example .claude/settings.json
```

3. Inicie nova sessão Claude Code para os hooks serem carregados.

## O que cada hook faz

### PostToolUse · Edit/Write

- **typecheck** — após editar `.ts`/`.tsx`, roda `pnpm exec tsc --noEmit`. Mostra primeiros 50 erros (cap para não inundar contexto).
- **eslint --fix** — corrige problemas de lint automaticamente no arquivo editado.

> Estes rodam **em todo Edit/Write**. Se ficar lento em projeto grande, considerar:
> - Trocar `tsc --noEmit` por `tsc --incremental` (precisa `--build`)
> - Limitar com matcher mais específico

### Stop

- **git status** — ao terminar turno, mostra mudanças não-commitadas. Lembra o user de revisar antes de fechar a sessão.

## Custos

- typecheck após cada Edit ~ 2–5s em projeto médio (incremental cache ajuda)
- eslint --fix ~ 0.5–2s
- Trade-off: mais lento, **muito** mais seguro

## Variantes (não inclusas — referência)

### Hook para rodar testes do arquivo editado

```json
{
  "type": "command",
  "command": "if [[ \"$CLAUDE_TOOL_INPUT_FILE_PATH\" =~ \\.test\\.(ts|tsx)$ ]]; then pnpm exec vitest run --reporter=verbose \"$CLAUDE_TOOL_INPUT_FILE_PATH\"; fi"
}
```

### Hook para bloquear commit direto em main (PreToolUse · Bash)

```json
{
  "matcher": "Bash",
  "hooks": [
    {
      "type": "command",
      "command": "if echo \"$CLAUDE_TOOL_INPUT_COMMAND\" | grep -qE 'git push.*origin\\s+main'; then echo 'ERROR: push direto em main bloqueado' >&2; exit 2; fi"
    }
  ]
}
```

## Debugging

Hooks com erro **não interrompem** o Claude (a menos que retornem exit 2 explicitamente). Para debug:

```bash
# Ver execução de hooks
tail -f ~/.claude/logs/hooks.log
```
