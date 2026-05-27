# Fase 0 — Discovery

**Objetivo.** Sair de "tenho uma ideia + uma referência" para um brief escrito que o Claude pode usar em todas as fases seguintes sem perguntar de novo.

**Entradas (do user).**
- Uma ou mais **referências visuais** (URL de site competidor, screenshot, Figma, mood board).
- Descrição livre do produto.
- (Opcional) Público-alvo, modelo de negócio, prazo, restrições.

**Saídas (no projeto-alvo).**
- `BRIEF.md` — produto, ICP, modelo de negócio, princípios não-negociáveis.
- `REFERENCES.md` — links + screenshots + o que tirar de cada um (e o que **não** copiar).

## Passo a passo

### 1. Coletar a referência

Para cada referência que o user mencionar (URL ou nome de site):

- **Capturar via script Playwright headless** — ver fluxo completo em [00b-capture-reference.md](00b-capture-reference.md). Gera `references/<slug>/{full.png, full-mobile.png, page.html, styles.css, fonts.json, meta.json}`.
- Se o user disse só nome ("estilo Vercel"), confirmar URL antes de capturar.
- Se a referência é app fechado/atrás de login: pedir screenshot manual ao user, salvar em `references/<slug>/full.png`.
- **Não** baixar/imitar pixel a pixel — referência é vibe, não cópia.

> A captura é o que dá ao `design-extractor` (Fase 1) HTML e CSS reais pra extrair tokens — sem ela, ele só consegue chutar do screenshot.

Em `REFERENCES.md`, para cada uma:

```md
## <Nome> — <URL>

**O que tirar:** hierarquia tipográfica, paleta neutra, uso de mono em labels.
**O que NÃO copiar:** hero com blur-glow, pills coloridos, ícone-em-chip.
**Screenshot:** ![alt](references/<slug>.png)
```

### 2. Brief: as 8 perguntas

Se o user não respondeu, pergunte de uma vez via `AskUserQuestion` (não uma por uma). Default razoável vira recomendação.

1. **Nome do produto.**
2. **One-liner** (uma frase que descreve o produto).
3. **Público-alvo primário** (B2B / B2C / B2B-first com B2C / outro).
4. **Modelo de negócio** (assinatura, transação, contratos enterprise, freemium).
5. **Idioma do V0** (PT-BR default; preparar schema para multi-idioma).
6. **Princípios não-negociáveis** (defaults: comfort em sessões longas, dark mode default, WCAG 2.2 AA, aesthetic equals functional).
7. **Restrições conhecidas** (compliance, prazo, orçamento, integrações obrigatórias).
8. **Anti-positioning** ("o que este produto **não** é").

### 3. Validar com o user antes de escrever

Depois das respostas, **mostre um resumo de 10 linhas** e peça confirmação:

> "Vou registrar isto como brief. Confirma ou ajusta?"

Só escreva `BRIEF.md` depois do "confirmo".

### 4. Escrever os arquivos

- Copie [templates/BRIEF.md.tpl](../templates/BRIEF.md.tpl) → `BRIEF.md`, substituindo placeholders.
- Copie [templates/REFERENCES.md.tpl](../templates/REFERENCES.md.tpl) → `REFERENCES.md`.
- Crie pasta `references/` no projeto-alvo para screenshots.

### 5. Commit

```bash
git add BRIEF.md REFERENCES.md references/
git commit -m "docs: brief inicial e referências"
```

## Quality gate desta fase

Antes de seguir para Fase 1, confirmar com o user:

- [ ] `BRIEF.md` cobre as 8 perguntas
- [ ] Pelo menos 1 referência com "o que tirar" e "o que NÃO copiar"
- [ ] Princípios não-negociáveis listados
- [ ] Anti-positioning explícito

## Anti-padrões

- ❌ Pular discovery porque "o user já disse o suficiente no prompt". Sempre vale ler de volta o brief para o user confirmar.
- ❌ Aceitar 1 referência genérica tipo "estilo Vercel". Forçar especificidade.
- ❌ Decidir paleta/tipografia aqui. Isso é a Fase 1.
