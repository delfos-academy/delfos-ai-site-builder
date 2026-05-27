# {{PROJECT_NAME}} — Performance

> Orçamentos, estratégia de rendering/cache, otimizações. Documento vivo: toda otimização entregue vira uma linha aqui (PR + before/after).

## Targets quantitativos

### Core Web Vitals (RUM via Vercel Analytics)

| Página | LCP | INP | CLS |
|---|---|---|---|
| Landing (`/`) | < 1.8s | < 200ms | < 0.05 |
| Login (`/login`) | < 1.5s | < 100ms | < 0.05 |
| Dashboard (auth) | < 2.0s | < 200ms | < 0.10 |
| Página de conteúdo principal | < 2.5s | < 200ms | < 0.10 |
| Admin | < 2.5s | < 200ms | < 0.10 |

### Lighthouse (mobile + desktop)

| Página | Mín. | Target |
|---|---|---|
| Landing | 95 | 99 |
| Login | 95 | 99 |
| Dashboard | 90 | 95 |
| Conteúdo | 90 | 95 |

### Bundle JS (gzipped, por rota)

| Rota | Budget |
|---|---|
| `/` (landing) | ≤ 80 KB |
| `/login` | ≤ 60 KB |
| `/dashboard` | ≤ 150 KB |
| Página de conteúdo | ≤ 200 KB |

## Rendering strategy

Decisão por página:

| Página | Modo | Justificativa |
|---|---|---|
| `/` (landing) | Static / PPR | Conteúdo público estável |
| `/pricing` | Static | Conteúdo estável |
| `/login`, `/signup` | Server (form action) | Server action |
| `/dashboard` | RSC + `use cache` por user | Personalizado, cacheable curto |
| `/admin/*` | RSC | Personalizado, cache curto |
| Conteúdo público | Static + ISR / PPR | Catálogo |
| API routes | Edge-friendly se possível | Webhooks são Node |

Uso de `use cache` directive em RSCs com `cacheLife` e `cacheTag` para invalidação seletiva.

Streaming com `<Suspense>` em páginas com queries pesadas.

## Caching layers

- **Vercel Runtime Cache** (per-region KV) — para queries de catálogo
- **HTTP cache headers** (Cache-Control, s-maxage, stale-while-revalidate) em endpoints públicos
- **DB query caching** (Drizzle + Redis se necessário) — só quando profiling mostrar hot query
- **CDN cache** (Vercel default + invalidação por tag)

## Assets

### Imagens

- `next/image` em **todas** as imagens (sem `<img>` direto)
- AVIF / WebP automático
- `sizes` prop preenchido em imagens responsivas
- `priority` em hero image
- Placeholders blur em imagens grandes (`placeholder="blur"`)

### Fontes

- `next/font` (sem `<link rel="stylesheet">` para Google Fonts)
- Subsetting para o locale ativo
- `display: swap`
- Máximo 2 famílias de fonte (display + mono)

### Vídeo

- {{VIDEO_PROVIDER}} embed via iframe lazy (`loading="lazy"`)
- Quando custos justificarem: migrar para Mux / Bunny CDN com HLS

### Ícones

- `lucide-react` com tree-shaking (importar individualmente: `import { Check } from "lucide-react"`)
- Sem icon libs full (Heroicons full, Material Icons)

## JavaScript

- Bundle analyzer integrado em CI: `pnpm build && pnpm analyze`
- **Libs a evitar:** moment (use date-fns ou Intl), lodash full (importar individual), polyfills grandes
- Lazy load via `next/dynamic` para componentes pesados (editor MDX, charts, drag-drop)
- Server components > client components sempre que possível

## Database

- Indexes documentados (lista abaixo a ser preenchida via `EXPLAIN ANALYZE` em queries hot)
- N+1 detection: cada query nova é revisada para não causar N+1
- Drizzle `neon-http` é HTTP — sem connection pool TCP, sem cold start
- Read replicas: só quando RUM mostrar bottleneck de DB

### Indexes ativos

| Tabela | Coluna(s) | Razão |
|---|---|---|
| {{TABLE_1}} | {{INDEX_1}} | {{INDEX_1_REASON}} |
| {{TABLE_2}} | {{INDEX_2}} | {{INDEX_2_REASON}} |

## Real User Monitoring

- Vercel Analytics — ativo desde V0
- Vercel Speed Insights — ativo
- Sentry Performance — ativo na Fase 5
- Dashboard custom para business metrics (conversion funnel) — pós-V0

## Per-page audits

| Rota | Última audit | Lighthouse mobile | Lighthouse desktop | PR |
|---|---|---|---|---|
| `/` | {{DATE}} | {{SCORE_M}} | {{SCORE_D}} | {{PR}} |
| `/login` | {{DATE}} | {{SCORE_M}} | {{SCORE_D}} | {{PR}} |
| `/dashboard` | {{DATE}} | {{SCORE_M}} | {{SCORE_D}} | {{PR}} |

## Como usar este documento

1. Antes de fechar Fase 5, rodar Lighthouse em todas as páginas-chave.
2. Toda task "perf melhorou X em Y%" → linha aqui + PR linkado.
3. PRs que regridem perf > 5% devem ser questionados.

## Skills relevantes

- `ui-ux-pro-max` (otimização visual)
- `verify` (rodar Lighthouse no app real)
