# {{PROJECT_NAME}} — Referências

> O que estamos olhando para inspirar o design e o produto. Para cada referência: **o que tirar** e **o que NÃO copiar**.

## Como usar este documento

- Referência é **vibe**, não cópia pixel-a-pixel.
- Sempre que adicionar uma, anotar 2 a 4 elementos específicos para tirar e 2 a 4 para **não** copiar.
- Screenshots vivem em `references/` (gitignored? Decisão do projeto. Default: commitar).

---

## {{REFERENCE_1_NAME}}

- **URL:** {{REFERENCE_1_URL}}
- **Categoria:** {{REFERENCE_1_CATEGORY}} (direto / análogo / adjacente)
- **Screenshot:** ![alt](references/{{REFERENCE_1_SLUG}}.png)

**O que tirar:**
- {{R1_TAKE_1}}
- {{R1_TAKE_2}}
- {{R1_TAKE_3}}

**O que NÃO copiar:**
- {{R1_AVOID_1}}
- {{R1_AVOID_2}}

---

## {{REFERENCE_2_NAME}}

- **URL:** {{REFERENCE_2_URL}}
- **Categoria:** {{REFERENCE_2_CATEGORY}}
- **Screenshot:** ![alt](references/{{REFERENCE_2_SLUG}}.png)

**O que tirar:**
- {{R2_TAKE_1}}
- {{R2_TAKE_2}}

**O que NÃO copiar:**
- {{R2_AVOID_1}}

---

## Síntese cruzada

Padrões recorrentes entre as referências que vamos adotar:

- {{SHARED_PATTERN_1}}
- {{SHARED_PATTERN_2}}

Anti-padrões recorrentes que vamos evitar:

- {{SHARED_ANTIPATTERN_1}}
- {{SHARED_ANTIPATTERN_2}}

## "Don'ts" universais (vêm do design system)

Independente das referências, estes nunca aparecem em {{PROJECT_NAME}}:

- Gradientes (`linear-gradient`, `radial-gradient`, `bg-gradient-to-*`)
- Blur-glow halos atrás de hero/sidebar
- Icon-in-tinted-rounded-square chips
- Decorative pills ("Platform · PT-BR")
- Ícones decorativos (Sparkles, etc)
- Inter / Roboto / Arial / system-ui
- Três colunas iguais ícone-título-parágrafo
- Dark mode puro `#000` ou `#0d0d0d` sem hue bias
