# {{PROJECT_NAME}} — Design System

> Source of truth visual. Tokens, tipografia, geometria, componentes. Brand-forward, autoral, não AI-default.

## 1. Essência

{{PROJECT_NAME}} é {{ESSENCE_DESCRIPTION}}. A interface deve ler como **produto autoral**, não template montado. Três princípios:

- **{{PRINCIPLE_1}}** — {{PRINCIPLE_1_DETAIL}}
- **{{PRINCIPLE_2}}** — {{PRINCIPLE_2_DETAIL}}
- **{{PRINCIPLE_3}}** — {{PRINCIPLE_3_DETAIL}}

## 2. Logo

{{LOGO_DESCRIPTION}}

- **Mark:** `components/brand/logo-mark.tsx` (`<LogoMark />`, mono via `currentColor`, default na cor da marca)
- **Wordmark:** `components/brand/wordmark.tsx` — mark + "{{PROJECT_NAME}}" em {{LOGO_FONT_WEIGHT}}
- **App icon / favicon:** `app/icon.svg`
- **Motivo de marca reutilizável:** {{BRAND_MOTIF}}

## 3. Cor

Tokens em `app/globals.css` como **HSL channels** (3 números separados por espaço, sem `hsl()` no valor). Dark é canônico; light existe para paridade.

### Superfícies (dark canônico, ladder com bias de hue ~{{BRAND_HUE}})

- **Background** `{{BG_HSL}}`
- **Card** `{{CARD_HSL}}`
- **Card elevated** `{{CARD_ELEVATED_HSL}}`
- **Border** `{{BORDER_HSL}}` · **Border strong** `{{BORDER_STRONG_HSL}}`

Diferencie superfícies subindo o ladder (background → card → elevated). **Nunca por gradient.**

### Marca e semântica

- **Primary** `{{BRAND_PRIMARY_HSL}}` ({{BRAND_PRIMARY_HEX}}) — progresso, conclusão, CTA primário **apenas**
- **Primary hover** `{{BRAND_PRIMARY_HOVER_HSL}}`
- Destructive `{{DESTRUCTIVE_HSL}}` · Warning `{{WARNING_HSL}}` · Info `{{INFO_HSL}}` · Success (= primary se brand for funcional-verde)

### Texto

- Foreground `{{FG_HSL}}` (~branco)
- Muted `{{MUTED_HSL}}` (silver levemente quente/frio)

## 4. Tipografia

- **Display + Body: {{DISPLAY_FONT}}** (`{{DISPLAY_FONT_VAR}}`, weights {{DISPLAY_FONT_WEIGHTS}})
- **Mono: {{MONO_FONT}}** (`{{MONO_FONT_VAR}}`) — eyebrows, labels, code, números tabulares
- **NUNCA Inter, Roboto, Arial, system-ui.** É o tell #1 de AI-default.
- Headlines: weight {{HEADLINE_WEIGHT}}, tracking `-0.02em`, line-height ~1.05
- `.text-eyebrow` — mono, uppercase, 10.5px, letter-spacing 0.18em
- `.num` — tabular numerals para XP, contagens, durações

Type scale: 12, 14, 16, 18, 20, 24, 30, 36, 48, 60 px.
Line height: 1.5 body / 1.75 textos longos.

## 5. Geometria (radius)

Squarer than soft. **No pills.**

- `--radius-sm 4px` · `--radius-md 6px` · `--radius-lg 8px` · `--radius-xl 12px`
- Buttons & inputs: `rounded-md` (6px)
- Cards: `rounded-lg` (8px)
- Chips/badges: ~5px
- Progress bars: ~3px
- **Full-round (`9999px`) APENAS para avatares.** Todo o resto é squared.

## 6. Spacing & layout

- Escala 4-based: 4, 8, 12, 16, 24, 32, 48, 64, 96 px
- Max width de leitura: 65ch para body
- Whitespace é asset; não comprimir
- 1 H1 por página, H2 para seções

## 7. Componentes

- **Button** (`components/ui/button.tsx`): solid primary, **flat** — sem scale-on-hover, hover darken só. Variantes: default / secondary / outline / ghost / link / destructive. Sizes sm/default/lg/xl + squared icon.
- **Card:** flat `bg-card`, `interactive` opcional vira hover-to-elevated. Sem borda por default; profundidade pelo ladder.
- **Badge:** chip squared, tabular numerals.
- **Input:** inset-border shadow (recessed), squared, focus ring usando `--brand` com 50% alpha.
- **Toast:** Sonner, top-center, default 5s.

## 8. Do / Don't (não negociável)

### Do
- Surface ladder **flat** para profundidade
- Cor de marca para progresso/conclusão/CTA primário **apenas**
- Squared geometry; hairline rules; índices numerados
- Tabular numerals para tudo numérico
- 1 motif de marca repetível

### Don't
- **No gradientes** (`linear-gradient`, `radial-gradient`, `bg-gradient-to-*`)
- **No blur-glow halos** atrás de hero/sidebar/orbs
- **No icon-in-tinted-rounded-square chips** (use número, regra lateral, bold type)
- **No decorative pills** ("Platform · {{PT_PRIMARY_LOCALE}}")
- **No ícones decorativos** (Sparkles, etc) — só funcionais
- **No Inter / Roboto / Arial / system-ui**
- **No pills** (exceto avatares)
- **No three-column icon-title-paragraph** repetitivo no hero
- **No dark `#000` ou `#0d0d0d` puro** — sempre com hue bias

## 9. Motion & micro-interactions

- Duração: 150 / 200 / 300ms
- Easing: ease-out para entrada, ease-in-out para state
- Hover: color shift, **não escala**
- Loading: skeleton > spinner
- `prefers-reduced-motion` respeitado em todas as animações

## 10. Acessibilidade (WCAG 2.2 AA)

- Contrast ratio ≥ 4.5:1 em todo texto
- Focus visible em **tudo** (ring com `--brand`)
- Skip links no top
- Aria labels onde necessário
- Color blindness testado (usar Stark ou similar)

## 11. Responsive

Breakpoints Tailwind default. Verificar em **375 / 768 / 1024 / 1440px**.

- Sidebar admin collapse < `md`
- Card grids: 4 → 3 → 2 → 1

## 12. Dark mode specifics

- Dark é default no `<html data-theme="dark">`
- Cores não são "invertidas" — são **recriadas** para o mode
- Imagens com filtro adaptado se necessário (`.dark img.illustration { filter: invert(...) hue-rotate(...) }`)
- Syntax highlighting com tema apropriado por mode

## 13. Tokens em `app/globals.css` (Tailwind v4)

```css
@import "tailwindcss";

@theme {
  --color-background: hsl({{BG_HSL}});
  --color-card: hsl({{CARD_HSL}});
  --color-card-elevated: hsl({{CARD_ELEVATED_HSL}});
  --color-border: hsl({{BORDER_HSL}});
  --color-foreground: hsl({{FG_HSL}});
  --color-muted: hsl({{MUTED_HSL}});
  --color-brand: hsl({{BRAND_PRIMARY_HSL}});
  --color-brand-hover: hsl({{BRAND_PRIMARY_HOVER_HSL}});
  --color-destructive: hsl({{DESTRUCTIVE_HSL}});
  --color-warning: hsl({{WARNING_HSL}});
  --color-info: hsl({{INFO_HSL}});

  --radius-sm: 4px;
  --radius-md: 6px;
  --radius-lg: 8px;
  --radius-xl: 12px;

  --font-display: var({{DISPLAY_FONT_VAR}}), ui-sans-serif, system-ui;
  --font-mono: var({{MONO_FONT_VAR}}), ui-monospace, SFMono-Regular;
}

:root {
  /* light mode overrides, se houver */
}

[data-theme="dark"] {
  /* mantém os defaults acima (dark é canônico) */
}
```

## Como usar este documento

1. Antes de criar componente novo, checar se já existe pattern aqui
2. PRs visuais devem referenciar **token name**, nunca hex direto
3. Quarterly visual review com skill `ui-ux-pro-max`
