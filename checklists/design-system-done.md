# Checklist — Design System (Fase 1)

Antes de seguir para Fase 2 (Architecture):

## Documentação
- [ ] `DESIGN_SYSTEM.md` cobre as 13 seções do template
- [ ] Tokens listados em HSL (3 números separados por espaço, sem `hsl()`)
- [ ] Do/Don't (§8) personalizado para o produto (não copia-cola genérico)

## Código aplicado
- [ ] `app/globals.css` com `@theme` (Tailwind v4 CSS-first) e tokens
- [ ] `app/layout.tsx` carrega 2 fontes via `next/font`, **nenhuma é Inter/Roboto/Arial**
- [ ] `<html lang="{{PT_PRIMARY_LOCALE}}">` no `app/layout.tsx`
- [ ] `components/brand/logo-mark.tsx` existe e usa `currentColor`
- [ ] `app/icon.svg` existe (favicon)

## shadcn inicializado
- [ ] `pnpm dlx shadcn@latest init` rodado
- [ ] `components.json` no repo
- [ ] Primitives V0 instaladas: button, input, label, card, dropdown-menu, separator, sonner
- [ ] `button.tsx` editado para refletir o design (sem hover-scale, hover darken só)

## Geometria
- [ ] `--radius-sm/md/lg/xl` definidos (4/6/8/12px)
- [ ] Sem `rounded-full` ou `rounded-pill` em components não-avatar

## Dark mode
- [ ] `data-theme="dark"` aplicado no `<html>` via `next-themes`
- [ ] Light mode existe (mesmo que apenas paridade)
- [ ] **NÃO usa preto puro** (`#000`, `#0d0d0d`) — tem hue bias

## Anti-AI checks (do/don'ts §8 do DESIGN_SYSTEM)
- [ ] **Zero gradientes** (search por `linear-gradient`, `radial-gradient`, `bg-gradient-to-*` retorna nada)
- [ ] **Zero blur-glow halos** (search por `blur-3xl`, `blur-2xl` retorna nada em hero/sidebar)
- [ ] **Zero icon-in-tinted-rounded-square chips** na home/marketing
- [ ] **Zero decorative pills** com pontos meio (`·`)
- [ ] **Zero ícones decorativos** (Sparkles, etc) — só funcionais
- [ ] **Zero `font-family: Inter`** no CSS ou config

## Validação visual
- [ ] Snapshot light + dark capturado
- [ ] Testado em 375px (mobile) e 1440px (desktop)
- [ ] User aprovou explicitamente os snapshots

## Acessibilidade básica
- [ ] Contrast ratio ≥ 4.5:1 em todo texto (testado com browser devtools)
- [ ] Focus ring visível em todos os botões e inputs
- [ ] `prefers-reduced-motion` respeitado se houver animação

## Quality gate
- [ ] `pnpm typecheck` zero erros
- [ ] `pnpm lint` zero warnings
- [ ] `pnpm build` sucesso
