# Fase 1 — Design System

**Objetivo.** Produzir um design system **autoral** (não AI-default) já materializado em código antes de qualquer feature ser implementada. Tokens, tipografia, geometria, componentes e do/don't.

**Entradas.** `BRIEF.md`, `REFERENCES.md`.

**Saídas.**
- `DESIGN_SYSTEM.md` no projeto-alvo (template em [templates/DESIGN_SYSTEM.md.tpl](../templates/DESIGN_SYSTEM.md.tpl)).
- `app/globals.css` com os tokens HSL.
- `app/layout.tsx` com `next/font` carregando as duas fontes escolhidas.
- Logo mínimo em `components/brand/logo-mark.tsx` (mono via `currentColor`).
- `components.json` do shadcn rodado.

## Passo a passo

### 1. Extrair design das referências

Use o subagent `design-extractor` (em [agents/design-extractor.md](../agents/design-extractor.md)). Em ambientes sem suporte a subagents (Cursor, uso manual), usar o sub-prompt equivalente: [prompts/extract-design-from-reference.md](../prompts/extract-design-from-reference.md).

Saída esperada do extractor (interno, não vai pro disco):

- **Essência** em 3 adjetivos (ex: "structured, branded-dark, functional-color").
- **Paleta de superfícies** (background + card + elevated + border) em HSL.
- **1 cor de marca** (uma só, funcional — progresso/CTA, não decorativa).
- **2 fontes**: display/body + mono. **Nunca Inter** (AI tell). Hanken Grotesk, Geist, Space Grotesk, IBM Plex Sans são candidatos seguros.
- **Geometria**: radius scale (squarer = autoral; pills = AI default).

### 2. Chamar `ui-ux-pro-max`

Para todo trabalho visual significativo, chamar a skill `ui-ux-pro-max` via tool `Skill`. Passar o brief + referências + extração inicial.

### 3. Aplicar os 10 "don'ts" do AI-default

Embutidos no template (`DESIGN_SYSTEM.md.tpl` §7). Repetir aqui para o Claude:

- **Sem gradientes** (`linear-gradient`, `radial-gradient`, `bg-gradient-to-*`).
- **Sem blur-glow halos** atrás de hero/sidebar/orbs.
- **Sem icon-in-tinted-rounded-square chips.** Use índices numerados, regra lateral, ou bold type.
- **Sem decorative pills** ("Platform · PT-BR", etc).
- **Sem ícones decorativos** (Sparkles, etc) — ícones devem ser funcionais.
- **Sem Inter, Roboto, Arial, system-ui.** É o tell #1.
- **Sem pills**. Tudo squared (`rounded-md` 6px máximo em botões/inputs, `rounded-lg` 8px em cards).
- **Sem três colunas iguais ícone-título-parágrafo** na home.
- **Sem dark mode "preto puro" (`#000` ou `#0d0d0d`)**. Adicione um bias de hue (verde, azul, sépia).
- **Sem cor decorativa**. Cor de marca = ação/progresso/CTA, nada mais.

### 4. Escrever tokens em `globals.css` (Tailwind v4 CSS-first)

Template em [templates/DESIGN_SYSTEM.md.tpl](../templates/DESIGN_SYSTEM.md.tpl) tem o bloco pronto. Variáveis em **HSL channels** (3 números separados por espaço), nunca hex direto — permite `hsl(var(--brand) / 0.5)`.

### 5. Componentes base do shadcn

```bash
pnpm dlx shadcn@latest init
pnpm dlx shadcn@latest add button input label card dropdown-menu separator sonner
```

Depois **edite** o `button.tsx` para refletir o design system (sem escala-on-hover, hover darken só, sem gradient).

### 6. Componente de marca

Mesmo se o user não tiver logo, crie um `<LogoMark />` simples baseado em uma forma geométrica (triângulo, círculo cortado, monograma). Mono via `currentColor`. Sem PNG.

### 7. Snapshot visual mínimo

Antes de fechar a fase:

- Rodar `pnpm dev`.
- Visitar `/` (uma página vazia com `<LogoMark />` + heading + button) em **light e dark**.
- Capturar screenshot e mostrar pro user.
- Pedir feedback **antes** de partir para arquitetura.

## Quality gate

Checklist em [checklists/design-system-done.md](../checklists/design-system-done.md).

Sintetizando:
- [ ] `DESIGN_SYSTEM.md` cobre 8 seções (essência, logo, cor, tipografia, geometria, componentes, do/don't, responsive)
- [ ] Tokens HSL aplicados em `app/globals.css`
- [ ] 2 fontes via `next/font`, nenhuma é Inter
- [ ] Squared geometry (no pills exceto avatares)
- [ ] Snapshot visual aprovado pelo user
- [ ] Zero gradientes / blur-glow / icon-chips

## Anti-padrões

- ❌ Pular para "vamos só usar shadcn default". Default é AI-default.
- ❌ Escolher 5 cores. Brand color é **uma**.
- ❌ Decidir tipografia sem testar — sempre carregar via `next/font` e ver renderizado.
- ❌ Implementar features antes do snapshot visual ser aprovado.
