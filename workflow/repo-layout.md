# Layout do repo (regra transversal)

> Aplicada em **toda fase**. A raiz do projeto-alvo é estritamente reservada para arquivos que **precisam** estar lá (configs lidos por convenção). Todo o resto fica em pastas.
>
> Motivação: a raiz suja com 15 `.md` espalhados torna o repo difícil de navegar pra humanos e força o Claude a varrer arquivos irrelevantes em toda sessão.

## Whitelist da raiz

**Permitido na raiz** (e somente isto):

### Documentação mínima
- `README.md` — convenção GitHub (descrição, install, run)
- `CLAUDE.md` — convenção Claude Code (carregado automaticamente em toda sessão)
- `LICENSE`, `CONTRIBUTING.md`, `CHANGELOG.md` (opcionais, se aplicáveis)

### Configs Node/TS
- `package.json`, `pnpm-lock.yaml` (ou yarn.lock / package-lock.json)
- `tsconfig.json`, `tsconfig.*.json`
- `.npmrc`, `.nvmrc`

### Configs Next
- `next.config.ts` (ou `.mjs`)
- `proxy.ts` (Next 16 middleware)
- `instrumentation.ts`, `instrumentation-client.ts`

### Configs build / lint / format
- `eslint.config.mjs` (ou `.eslintrc.*`)
- `.prettierrc`, `prettier.config.*`
- `postcss.config.mjs` (ou `.cjs`)
- `tailwind.config.*` (se Tailwind 3; Tailwind 4 CSS-first dispensa)
- `components.json` (shadcn)

### Configs vendor
- `vercel.json`
- `drizzle.config.ts`
- `vitest.config.ts`
- `playwright.config.ts`

### Env / Git / CI top-level
- `.env.example` (commitado)
- `.env.local`, `.env.production` (gitignored)
- `.gitignore`, `.gitattributes`
- `.dockerignore`, `Dockerfile` (se aplicável)
- `.editorconfig`

## Tudo o resto vai pra pasta

| Tipo de arquivo | Pasta |
|---|---|
| Documentação do produto (BRIEF, PLAN, DESIGN_SYSTEM, ARCHITECTURE, etc) | `docs/` |
| Milestones | `docs/milestones/` |
| Operations (perf, security) | `docs/operations/` |
| Referências visuais (capturas) | `docs/references/<slug>/` |
| ADRs (decisions) | `docs/decisions/` |
| Postmortems / incidents | `docs/postmortems/`, `docs/incidents/` |
| Código de aplicação | `app/`, `components/`, `lib/` |
| Testes | `tests/` (+ `*.test.ts` co-located) |
| Scripts utilitários | `scripts/` |
| Assets estáticos | `public/` |
| Migrations geradas | `drizzle/` (gerado pelo drizzle-kit) |
| Dados estáticos JSON/CSV | `lib/placeholders/` ou `data/` |

## Proibido na raiz (mover, sem exceção)

- ❌ Qualquer `.md` que não seja README/CLAUDE/LICENSE/CONTRIBUTING/CHANGELOG → `docs/`
- ❌ `BRIEF.md`, `PLAN.md`, `ARCHITECTURE.md`, `DESIGN.md`, `DESIGN_SYSTEM.md`, `WORKFLOW.md`, `BACKLOG.md`, `CODE_ORGANIZATION.md` na raiz → `docs/`
- ❌ Pastas `MILESTONES/`, `OPERATIONS/`, `REFERENCES/` na raiz → `docs/milestones/`, `docs/operations/`, `docs/references/`
- ❌ `.ts`/`.tsx` que não é arquivo de config conhecido → `app/`, `lib/`, `components/`
- ❌ Scripts soltos (`*.sh`, `*.mjs`) → `scripts/`
- ❌ Arquivos de dados (`*.json` que não é config, `*.csv`, `*.sql`) → `lib/placeholders/`, `data/`, ou `drizzle/`
- ❌ Notas pessoais (`notes.md`, `todo.md`, `scratch.md`) → não commitar. Use `BACKLOG.md` em `docs/` ou TODO comments com dono.

## Por que CLAUDE.md fica na raiz

`CLAUDE.md` é exceção porque o Claude Code o carrega **automaticamente** se estiver na raiz. Movê-lo pra `docs/` perde a integração nativa.

Se a equipe achar feio ter `CLAUDE.md` visível, alternativa é deixar **apenas um stub** na raiz:

```md
# CLAUDE.md (stub)

As convenções deste projeto estão em [docs/CLAUDE.md](./docs/CLAUDE.md).
Este stub redireciona apenas para preservar a convenção de auto-load do Claude Code.

@docs/CLAUDE.md
```

Default da skill: `CLAUDE.md` completo na raiz (sem stub) — mais simples.

## Quality gate de limpeza

Checklist em [checklists/repo-cleanliness.md](../checklists/repo-cleanliness.md). Aplicado em todo PR.

Comando rápido pra auditar:

```bash
# Listar tudo na raiz que NÃO está na whitelist
ls -1 | grep -vE '^(README\.md|CLAUDE\.md|LICENSE|CONTRIBUTING\.md|CHANGELOG\.md|package\.json|pnpm-lock\.yaml|tsconfig.*\.json|\.npmrc|\.nvmrc|next\.config\.(ts|mjs)|proxy\.ts|instrumentation(-client)?\.ts|eslint\.config\.mjs|\.eslintrc.*|\.prettierrc.*|prettier\.config\..*|postcss\.config\..*|tailwind\.config\..*|components\.json|vercel\.json|drizzle\.config\.ts|vitest\.config\.ts|playwright\.config\.ts|\.env\.example|\.env\.local|\.env\.production|\.gitignore|\.gitattributes|\.dockerignore|Dockerfile|\.editorconfig|app|components|lib|tests|scripts|public|docs|drizzle|\.next|\.git|node_modules)$'
```

Se devolver alguma coisa, é uma violação — mover ou justificar no PR.

## Aplicação por fase

| Fase | O que cria/move |
|---|---|
| **0** | Cria `docs/BRIEF.md`, `docs/REFERENCES.md`, `docs/references/` (não na raiz) |
| **0b** | Captura em `docs/references/<slug>/` |
| **1** | Cria `docs/DESIGN_SYSTEM.md` (não na raiz) |
| **2** | Cria `docs/ARCHITECTURE.md`, `docs/operations/SECURITY.md`, `docs/operations/PERFORMANCE.md`, `docs/CODE_ORGANIZATION.md`. **Único `.md` que vai pra raiz nesta fase: `CLAUDE.md`** |
| **3** | Cria `docs/PLAN.md`, `docs/milestones/NN-*.md`, `docs/WORKFLOW.md`, `docs/BACKLOG.md` |
| **4** | **Limpeza obrigatória de raiz no M00-bootstrap** (mover arquivos legados pra pastas corretas se herdou repo bagunçado) |
| **5** | Cria `app/sitemap.ts`, `app/robots.ts`, `app/manifest.ts` (na pasta correta). Páginas legais em `app/(marketing)/privacy/page.tsx` etc, não em md soltos |

## Quando herda repo bagunçado (limpeza no bootstrap)

Se a skill é aplicada num repo que **já existe** com arquivos na raiz fora da whitelist, o **M00-bootstrap** inclui uma task explícita:

```md
- [ ] Auditar raiz com comando da quality gate
- [ ] Mover .md fora da whitelist pra docs/
- [ ] Mover .ts/.tsx solto pra pasta apropriada
- [ ] Mover scripts soltos pra scripts/
- [ ] Atualizar imports/refs após movimentação
- [ ] Commit: `chore: organiza raiz do repo (move docs e scripts para subpastas)`
```

## Anti-padrões

- ❌ Criar `NOTES.md`, `TODO.md`, `IDEAS.md` na raiz → use `docs/BACKLOG.md`
- ❌ Criar `analysis-*.md` no meio do desenvolvimento (não criar `.md` exceto se solicitado — vale a regra do `CLAUDE.md`)
- ❌ Deixar arquivo "temporário" na raiz "só por hoje" — acumula
- ❌ Criar `data.json` na raiz pra mockar algo → `lib/placeholders/` ou `tests/fixtures/`
- ❌ Mover `CLAUDE.md` pra `docs/` (quebra auto-load)
