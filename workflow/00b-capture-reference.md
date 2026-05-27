# Fase 0b — Capturar referência visual

> Sub-passo da [Fase 0 — Discovery](00-discovery.md). Roda **antes** de chamar o subagent `design-extractor`. Garante que o agente trabalha com material real (HTML, CSS, screenshots), não só descrição.

## Quando rodar

- O user passou uma **URL** (ex: "olha o site da Linear").
- O user passou um **nome de produto** ("estilo Vercel", "tipo DataCamp").
- O user passou um **screenshot** já capturado (pular para passo 3).

## Saídas

Para cada referência, dentro do projeto-alvo:

```
references/
└── <slug>/                          ex: linear, vercel, datacamp
    ├── meta.json                    URL, título, viewport usado, timestamp
    ├── full.png                     screenshot full-page desktop (1440×N)
    ├── full-mobile.png              full-page mobile (375×N)
    ├── above-fold.png               somente a primeira dobra desktop
    ├── page.html                    HTML renderizado (após JS)
    ├── styles.css                   CSS resolvido das primeiras 30 regras críticas
    └── fonts.json                   font-families detectadas (debug)
```

## Passo a passo

### 1. Resolver "nome de site" para URL

Se o user disse "estilo Vercel", não "https://vercel.com":

- Confirme com o user via `AskUserQuestion`: "É vercel.com mesmo?" — evita capturar a página errada.
- Para referências famosas, **não chute** (linear.app vs linear.com, framer.com vs framer.app).

### 2. Capturar via script

Use o template em [scripts/capture-reference.mjs.tpl](../scripts/capture-reference.mjs.tpl). No projeto-alvo, copiar para `scripts/capture-reference.mjs` se ainda não existe e rodar:

```bash
pnpm dlx playwright install chromium    # uma vez
node scripts/capture-reference.mjs --url https://linear.app --slug linear
```

O script:
1. Abre Chromium headless em viewport 1440×900
2. Vai pra URL, espera `networkidle`
3. Captura full-page screenshot
4. Re-viewport para 375×812, captura mobile full-page
5. Volta a 1440×900, captura above-fold
6. Salva HTML renderizado
7. Extrai computed style das primeiras 30 regras CSS relevantes (body, h1-h3, a, button, p, etc)
8. Lista font-families únicas
9. Escreve `meta.json` com timestamp + URL canônica

### 3. Quando o user já forneceu screenshot

- Salvar em `references/<slug>/full.png` (renomeie se necessário).
- Criar `meta.json` mínimo (sem URL, só source: "user-provided").
- Pular para passo 4.

### 4. Captura por seção (opcional, mas recomendado)

Para referências importantes, o full-page sozinho é difícil pro extractor analisar com precisão. Recortar manualmente em seções:

```
references/<slug>/sections/
├── hero.png
├── pricing.png
├── nav.png
└── footer.png
```

O script pode aceitar `--selectors` opcionalmente para recortar por seletor CSS:

```bash
node scripts/capture-reference.mjs --url https://linear.app --slug linear \
  --selectors "header,main>section:nth-child(1),footer"
```

### 5. Atualizar REFERENCES.md

Adicionar entrada apontando para os artefatos:

```md
## Linear — https://linear.app

- Capturado em: 2026-05-27
- Artefatos: [references/linear/](references/linear/)
- Screenshots: ![desktop](references/linear/full.png) · [mobile](references/linear/full-mobile.png)

**O que tirar:**
- ...

**O que NÃO copiar:**
- ...
```

### 6. Passar pro extractor

Quando invocar o subagent `design-extractor` na Fase 1, **passar os caminhos dos arquivos baixados** no prompt, não só a URL. O subagent pode então:

- `Read references/linear/page.html` e procurar `font-family`, classes, estrutura
- `Read references/linear/styles.css` para HSL/RGB reais
- Ver `references/linear/full.png` (input visual)
- `Read references/linear/meta.json` para timestamp

## Limitações conhecidas

- **Sites com paywall/login** (Notion logado, app Linear interno) → não dá pra capturar headless. Pedir screenshot manual.
- **Sites com bot detection** (Cloudflare, Datadome) → o Playwright vai ser bloqueado. Considerar:
  - User envia screenshot manual
  - Usar `playwright-extra` com `puppeteer-extra-plugin-stealth` (pesar trade-off: dependência extra só por isso)
- **CSS modular / scoped** (Next, Vue) → as classes são hash. O `styles.css` extraído ajuda menos do que esperaria.
- **Heavy SPA** com carregamento progressivo → o `networkidle` pode demorar 30s. O script tem timeout de 60s; ajustar `--timeout` se necessário.

## Fallback se não houver Playwright

Se o projeto-alvo ainda não tem Playwright instalado (pré-bootstrap):

- Usar `WebFetch` tool do Claude pra pegar HTML básico (sem JS).
- Pedir screenshot manual ao user.
- Salvar em `references/<slug>/` mesmo assim — formato consistente importa.

## Alternativa: MCP de browser

Se o ambiente Claude tem `mcp__Claude_in_Chrome__*` ou `mcp__Claude_Preview__*` disponíveis, dá pra capturar sem instalar Playwright local:

```
mcp__Claude_in_Chrome__navigate({url: "https://linear.app"})
mcp__Claude_in_Chrome__resize_window({width: 1440, height: 900})
# capturar via tool específica de screenshot do MCP
```

Equivalente em saída, mas depende de o user ter o MCP server rodando. Default é o script Playwright (autocontido).

## Anti-padrões

- ❌ Chamar `design-extractor` só com a URL — o agente perde info quando não tem HTML/screenshot na mão.
- ❌ Capturar 10 referências "pra ter". Capturar 2-3 com qualidade.
- ❌ Commitar `references/` em `.gitignore`. Os artefatos **são** o source de verdade visual — devem estar versionados (são pequenos: ~200 KB cada).
- ❌ Tirar screenshot por celular (foto da tela do desktop). Use o script ou ferramenta nativa do SO (`Win+Shift+S` no Windows).
