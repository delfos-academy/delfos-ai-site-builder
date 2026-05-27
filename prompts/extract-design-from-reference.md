# Sub-prompt: extract-design-from-reference

Use quando precisar extrair design tokens estruturados a partir de uma referência visual (URL, screenshot, ou descrição do user).

## Como invocar

Embute o conteúdo abaixo no prompt do Claude (ou de um subagent), substituindo `{{REFERENCE_INPUT}}` pela referência.

---

Você está analisando esta referência visual para extrair um design system inicial.

**Referência:** {{REFERENCE_INPUT}}

Devolva exatamente este YAML (não markdown, não comentário, só o YAML):

```yaml
essence:
  adjectives: [<adj1>, <adj2>, <adj3>]    # ex: structured, branded-dark, functional-color
  feel: <1 frase descrevendo a vibe>

surfaces:
  # HSL em "H S% L%" format, separados por espaço dentro de cada string
  background: "<H S% L%>"
  card: "<H S% L%>"
  card_elevated: "<H S% L%>"
  border: "<H S% L%>"
  border_strong: "<H S% L%>"

brand:
  primary: "<H S% L%>"          # uma única cor de marca; funcional
  primary_hover: "<H S% L%>"
  destructive: "<H S% L%>"
  warning: "<H S% L%>"
  info: "<H S% L%>"

text:
  foreground: "<H S% L%>"       # near-white em dark mode
  muted: "<H S% L%>"

typography:
  display_font: <nome>           # NUNCA Inter, Roboto, Arial, system-ui
  display_weights: [400, 600, 800]
  mono_font: <nome>
  rationale: <por que esta combinação reflete a referência sem ser AI-default>

geometry:
  radius_sm: 4
  radius_md: 6
  radius_lg: 8
  radius_xl: 12
  pills_allowed: false           # default; só true para avatares

motif:
  description: <forma/elemento autoral repetível, ex: "triângulo com slot horizontal">
  usage: [<onde usar 1>, <onde usar 2>]

anti_patterns_to_avoid:
  - <coisa específica desta referência que NÃO queremos copiar 1>
  - <coisa específica desta referência que NÃO queremos copiar 2>

what_to_take:
  - <elemento específico da referência que queremos manter 1>
  - <elemento específico da referência que queremos manter 2>
```

## Regras de extração

1. **Cor de marca é UMA SÓ.** Se a referência tem múltiplas, escolha a funcional (CTA/progresso).
2. **Nunca proponha Inter, Roboto, Arial.** Candidatos seguros: Hanken Grotesk, Geist, Space Grotesk, IBM Plex Sans, Söhne, JetBrains Mono (para mono).
3. **Hue bias obrigatório.** Background não pode ser `0 0% N%` puro (cinza). Adicione 5–20° de hue (verde, azul, sépia, violeta).
4. **Squarer geometry.** Default radius máximo é 12px. Se a referência usa pills, marque `pills_allowed: false` e justifique.
5. **Identifique 2+ anti-patterns** da própria referência. (Ex: "logo embutido em pill verde", "hero com blur-glow rosa" — vamos pegar o resto mas largar isso).
6. **Identifique 2+ takeaways concretos.** Não vago tipo "tipografia boa" — "uso de mono em eyebrows com letter-spacing 0.18em".

## Validação antes de usar

Antes de aplicar a saída a `DESIGN_SYSTEM.md`:

- [ ] Background HSL não é `0 0% X%` (cinza puro)
- [ ] `brand.primary` é uma só cor
- [ ] `display_font` não é Inter/Roboto/Arial
- [ ] `pills_allowed: false`
- [ ] `anti_patterns_to_avoid` tem ≥ 2 itens
- [ ] `what_to_take` tem ≥ 2 itens
