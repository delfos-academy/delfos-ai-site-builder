# Otimização de tokens (regra transversal)

> Não é uma fase. É um conjunto de heurísticas que o Claude aplica em **toda** sessão pra trabalhar mais com menos contexto. Custo financeiro reduzido, respostas mais rápidas, menos "vou ler o arquivo todo de novo".

## Princípios

1. **Não ler o que já se sabe.**
2. **Não duplicar contexto entre main e subagents.**
3. **Carregar o necessário, não o disponível.**
4. **Delegar análise pesada para subagent (contexto isolado morre depois).**
5. **Cache funciona — não invalidar à toa.**

## Decisões estruturais da skill que economizam tokens

Estas já estão embutidas. **Reconhecer e respeitar:**

### PLAN.md fino + `MILESTONES/NN-*.md` separados

`PLAN.md` é índice de 150-200 linhas, carregado em toda sessão. Detalhes ficam em `MILESTONES/NN-*.md` — Claude lê **apenas o milestone ativo**. Sem carregar 900+ linhas de plano todo turno (o `IMPLEMENTATION_PLAN.md` da Delfos é o anti-exemplo).

### Public API por feature (`lib/<feature>/index.ts`)

Pra entender um módulo, Claude lê 1 arquivo (`index.ts`, ~20 linhas) em vez de N arquivos internos. Refatoração interna não exige reler consumidores.

### Limites de tamanho duros

Componente `.tsx` ≤ 250 linhas, action ≤ 400, lib ≤ 350. Cada arquivo cabe **inteiro** no contexto sem `Read offset/limit`. Sem `head`/`grep` defensivo.

### Co-location (`foo.test.ts` ao lado de `foo.ts`)

Quando edita `foo.ts`, Claude já sabe onde está o teste — não precisa `Glob '**/*.test.ts'`.

### CLAUDE.md curto

Carregado em **toda sessão** automaticamente. Manter < 200 linhas. Convenções essenciais + glossário. Detalhes vão pra arquivos linkados (ARCHITECTURE, CODE_ORGANIZATION).

### Templates determinísticos

Quando Claude precisa criar `BRIEF.md`, ele copia o `.tpl` e substitui placeholders — não inventa estrutura do zero. Economiza geração + reduz variância.

## Heurísticas para o Claude aplicar em todo turno

### Quando ler vs quando grep vs quando glob

| Situação | Tool |
|---|---|
| Sei o path exato | `Read` (com `limit` se sei seção) |
| Sei o nome do arquivo mas não o path | `Glob "**/<name>"` |
| Procurando uma string / símbolo | `Grep` (não Read + scan manual) |
| Pergunta aberta sobre o codebase | `Agent` (subagent isolado, não Read em série) |
| Vários arquivos pequenos relacionados | Read em paralelo (uma mensagem com várias chamadas) |

### Quando usar `Read offset` / `limit`

- Default: ler arquivo inteiro (limites de tamanho garantem que cabe).
- Só usar `offset/limit` quando: arquivo é gigante (schema legado, migration SQL grande, log). Nesses casos, pegar seção identificada via Grep antes.

### Quando NÃO ler

- Acabou de editar o arquivo (`Edit`/`Write`) → harness rastreia, não precisa re-ler para "confirmar".
- Já leu nesta sessão → confiar no contexto, não duplicar.
- É um `.lock`, `.min.js`, ou gerado → nunca útil.

### `Glob` antes de `Read`

Em projeto novo, `Read` direto sem saber se o arquivo existe gasta uma chamada que falha. Sempre `Glob` ou `Bash ls` se houver dúvida.

### Paralelismo agressivo em leituras independentes

```
# ✅ Bom — uma única mensagem com múltiplas calls
Read app/(app)/dashboard/page.tsx
Read lib/auth/index.ts
Read lib/db/schema.ts
Grep "requireUser" --output_mode files_with_matches

# ❌ Ruim — 4 turnos sequenciais
```

Independência: cada chamada não depende do resultado da outra. Se for explorar `app/dashboard/page.tsx` → seguir pra `lib/<que page importa>`, aí é sequencial mesmo.

### Subagents para queries com saída grande

- `Explore` (read-only) — varredura no codebase quando saída interessa só em síntese. **Não polui main context** com arquivos lidos.
- `general-purpose` — pesquisa web (referências, competitors). Resultado curto volta pro main.
- `design-extractor` — análise de referência visual (HTML + CSS + screenshot). Devolve só o YAML estruturado.
- `milestone-planner` — gerar PLAN.md + N MILESTONES. Lê BRIEF/ARCH/DESIGN, devolve markdown.
- `requirement-tester` — gera test files a partir de done criteria.

**Briefing do subagent é self-contained** (ele não vê a conversa). Vale a pena passar paths exatos + critério de sucesso explícito.

### WebFetch vs subagent

| Caso | Use |
|---|---|
| Sei a URL exata, quero conteúdo bruto | `WebFetch` no main (resultado é truncado por default — controlar) |
| Pesquisa exploratória ("vê o que tem em X site") | Subagent + WebSearch + WebFetch |
| Captura visual de referência | Script `capture-reference.mjs` (Playwright headless) — saída em disco, melhor que carregar HTML inteiro |

### Hooks que recortam saída

Hook que roda `pnpm typecheck` pode despejar 1000 linhas. Sempre **truncar** no hook (`| head -50`, `| tail -20`). Ver `hooks/settings.json.example`.

### Não compactar contexto cedo demais

O Claude tem prompt cache de 5min. Compactar contexto (rodar `/compact`) invalida o cache. Compactar é útil mas **caro** — só quando contexto está claramente inflado, não preventivamente.

### `@-references` vs full read (quando aplicável)

Quando a ferramenta suporta `@arquivo` no prompt, **prefere** ao Read explícito — usa cache do harness em vez de gastar tokens lendo de novo.

### Ler só a seção que importa

Pra entender "como `requireUser` funciona":

- ❌ `Read lib/auth/session.ts` inteiro (~250 linhas)
- ✅ `Grep "function requireUser" -A 30 lib/auth/session.ts` (~35 linhas)

Tradeoff: se vai mexer em várias coisas do arquivo, ler tudo é melhor. Pra entender 1 função, grepar.

## Heurísticas pro main agent quando orquestrando

### Fase 0-3: descobrir/planejar

- Carregar **só** o que cada fase precisa. Fase 1 não precisa de `ARCHITECTURE.md` (que ainda nem existe). Fase 3 lê BRIEF + DESIGN + ARCH, mas não cada milestone (ainda nem existe).
- Subagent `milestone-planner` recebe os 3 inputs e devolve os milestones — main agent não precisa "pensar" sobre eles passo-a-passo.

### Fase 4: implementar milestone

- Abrir **APENAS** `MILESTONES/<ativo>.md`, `CLAUDE.md` (já em contexto), `DESIGN_SYSTEM.md` se UI, `ARCHITECTURE.md` se schema.
- **Não abrir** milestones inativos.
- **Não abrir** arquivos de outras features que não estão no diff.
- Antes de mudar `lib/<feature>/foo.ts`: ler `lib/<feature>/index.ts` (public API) — se mudança é interna, não precisa olhar consumidores.

### Fase 5: launch hardening

- Ler `OPERATIONS/SECURITY.md` + `OPERATIONS/PERFORMANCE.md` quando entrar nessa fase.
- Hardening não precisa de detalhe das features anteriores — verifica artefatos finais.

## Anti-padrões caros (não fazer)

- ❌ `Read lib/db/schema.ts` (500-800 linhas) para descobrir se uma coluna existe → use `Grep "<colName>" lib/db/schema.ts -B 2 -A 2`
- ❌ Listar `Glob "**/*.tsx"` (centenas de paths) sem filtro
- ❌ Carregar todos os `MILESTONES/` no contexto "por garantia"
- ❌ `Read` após `Edit/Write` para "confirmar" que escreveu
- ❌ Re-ler `CLAUDE.md` no meio da sessão (já está no contexto base)
- ❌ Pedir ao subagent pra "explorar tudo" — sempre ter pergunta específica
- ❌ Repetir conteúdo de arquivo dentro de prompt de outro tool call (cache resolve)
- ❌ Print debug de arquivo inteiro em hook PostToolUse

## Monitoramento

- Se a sessão passou de 50k tokens com pouco trabalho útil, considerar `/compact` — mas só **depois** de fazer commit do que está pronto.
- Se um arquivo precisa ser lido várias vezes na sessão, vale fazer um snapshot no contexto principal de uma vez.

## Quem aplica essas regras

- **Main agent**: ler esta página no início da Fase 4 (e mantê-la em mente).
- **Hooks**: cortam ruído de saída automaticamente.
- **CLAUDE.md**: referencia este documento no projeto-alvo.
- **pre-merge-review**: não checa tokens (não é gate), mas se PR exigiu muitos turnos, considerar refatorar pra reduzir.
