# Checklist — Limpeza da raiz e organização de pastas

Aplicado em **todo PR**. Bloqueio se raiz tem arquivo fora da whitelist.

## Whitelist da raiz (apenas isto pode estar lá)

### Documentação mínima
- [ ] `README.md`
- [ ] `CLAUDE.md`
- [ ] `LICENSE`, `CONTRIBUTING.md`, `CHANGELOG.md` (se aplicáveis)

### Configs Node/TS
- [ ] `package.json`, lockfile (`pnpm-lock.yaml` / `yarn.lock` / `package-lock.json`)
- [ ] `tsconfig.json`, `tsconfig.*.json`
- [ ] `.npmrc`, `.nvmrc`

### Configs Next
- [ ] `next.config.ts` ou `.mjs`
- [ ] `proxy.ts` (Next 16 middleware)
- [ ] `instrumentation.ts`, `instrumentation-client.ts`

### Configs lint/format/build
- [ ] `eslint.config.mjs` ou `.eslintrc.*`
- [ ] `.prettierrc`, `prettier.config.*`
- [ ] `postcss.config.*`
- [ ] `tailwind.config.*` (se Tailwind 3)
- [ ] `components.json`

### Configs vendor
- [ ] `vercel.json`
- [ ] `drizzle.config.ts`
- [ ] `vitest.config.ts`
- [ ] `playwright.config.ts`

### Env / Git / CI
- [ ] `.env.example` (commitado), `.env.local` (gitignored)
- [ ] `.gitignore`, `.gitattributes`, `.dockerignore`, `Dockerfile` (se aplicável)
- [ ] `.editorconfig`

## Pastas permitidas na raiz

- [ ] `app/`, `components/`, `lib/`, `tests/`, `scripts/`, `public/`, `docs/`, `drizzle/`
- [ ] (automáticas) `.git/`, `.next/`, `node_modules/`, `.vercel/`

## Comando de auditoria

```bash
ls -1 | grep -vE '^(README\.md|CLAUDE\.md|LICENSE|CONTRIBUTING\.md|CHANGELOG\.md|package\.json|pnpm-lock\.yaml|tsconfig.*\.json|\.npmrc|\.nvmrc|next\.config\.(ts|mjs)|proxy\.ts|instrumentation(-client)?\.ts|eslint\.config\.mjs|\.eslintrc.*|\.prettierrc.*|prettier\.config\..*|postcss\.config\..*|tailwind\.config\..*|components\.json|vercel\.json|drizzle\.config\.ts|vitest\.config\.ts|playwright\.config\.ts|\.env\.example|\.env\.local|\.env\.production|\.gitignore|\.gitattributes|\.dockerignore|Dockerfile|\.editorconfig|app|components|lib|tests|scripts|public|docs|drizzle|\.next|\.git|node_modules|\.vercel)$'
```

Se devolver linha: violação. Mover ou justificar no PR.

## Violações comuns e onde mover

| Arquivo violador | Destino |
|---|---|
| `BRIEF.md`, `PLAN.md`, `ARCHITECTURE.md`, `DESIGN_SYSTEM.md` | `docs/` |
| `MILESTONES/`, `OPERATIONS/`, `REFERENCES/` (pastas) | `docs/milestones/`, `docs/operations/`, `docs/references/` |
| `NOTES.md`, `TODO.md`, `IDEAS.md`, `scratch.md` | **Não commitar**. Ideias vão pra `docs/BACKLOG.md` |
| `analysis-*.md`, `summary-*.md` | **Não commitar** (a skill proíbe criar .md sem ser pedido — ver CLAUDE.md) |
| `data.json`, `mock.json`, `seed.json` | `lib/placeholders/` ou `tests/fixtures/` |
| `*.sh`, `*.mjs` (script solto) | `scripts/` |
| `seed.ts`, `migrate.ts` (script utility) | `scripts/` |
| Arquivo `.ts` que não é config conhecido | Pertence a `app/`, `lib/`, ou `components/` — decidir pelo conteúdo |

## Estrutura interna de `docs/`

- [ ] Top de `docs/` contém arquivos UPPER_CASE: `BRIEF.md`, `REFERENCES.md`, `DESIGN_SYSTEM.md`, `ARCHITECTURE.md`, `PLAN.md`, `WORKFLOW.md`, `BACKLOG.md`, `CODE_ORGANIZATION.md`
- [ ] Subpastas em lowercase: `milestones/`, `operations/`, `references/`, `decisions/`, `incidents/`, `postmortems/`
- [ ] `docs/milestones/` contém só `NN-slug.md` (00-bootstrap, 01-…, etc)
- [ ] `docs/operations/` contém só `PERFORMANCE.md` e `SECURITY.md`
- [ ] `docs/references/<slug>/` contém artefatos de captura (full.png, page.html, styles.css, etc)
- [ ] `docs/decisions/NNNN-titulo.md` para ADRs grandes (decisão estrutural com 2+ trade-offs)

## Refs entre docs (links relativos)

- [ ] Dentro de `docs/`, links são relativos (`./PLAN.md`, `./milestones/00-bootstrap.md`)
- [ ] De `CLAUDE.md` (raiz) para `docs/`: `./docs/PLAN.md`
- [ ] De `README.md` (raiz) para `docs/`: `./docs/`

## Sem arquivos órfãos

- [ ] Nenhum arquivo em `docs/` que **não é referenciado** por nenhum outro doc nem é entry point conhecido
- [ ] Pasta `docs/decisions/` tem `README.md` se houver ADRs, listando-os

## Casos especiais

- **Migrations SQL geradas pelo drizzle-kit** → ficam em `drizzle/` na raiz (convenção drizzle-kit). OK.
- **Public assets** → `public/` (convenção Next). OK.
- **`/api/healthcheck.js` style routes** → não. Use App Router `app/api/healthcheck/route.ts`.

## Anti-padrões

- ❌ "Vou deixar só por hoje na raiz" — não, move agora
- ❌ Pasta `tmp/`, `wip/`, `legacy/` — não commitar
- ❌ Pasta `notes/` solta — vira `docs/`
- ❌ Múltiplos READMEs (`README.md` + `README-dev.md`) — consolidar
- ❌ `CLAUDE.md` em `docs/` (quebra auto-load do Claude Code)
- ❌ `package.json` em subpasta sem ser monorepo
