# Delfos Site Builder — Convenções do projeto

Stack locked: **Next.js 16 + Vercel + Neon + Drizzle + Tailwind v4 + shadcn/ui**.
Workflow completo em `.skill/workflow/`. Leia o documento da fase ativa antes de implementar.

## Fases

| Fase | Documento |
|---|---|
| 0 — Discovery | `.skill/workflow/00-discovery.md` |
| 1 — Design System | `.skill/workflow/01-design-system.md` |
| 2 — Arquitetura | `.skill/workflow/02-architecture.md` |
| 3 — Master Plan | `.skill/workflow/03-master-plan.md` |
| 4 — Execute Milestone | `.skill/workflow/04-execute-milestone.md` |
| 5 — Launch Hardening | `.skill/workflow/05-launch-hardening.md` |

## Regras de código (sempre ativas)

### TypeScript
- `strict: true`, `noUncheckedIndexedAccess: true`
- Zod em toda entrada externa (form, action, route)
- `import 'server-only'` em módulos com DB/secrets
- Server Components por padrão; `'use client'` só quando necessário

### Organização
- Estrutura **por feature**, não por tipo
- Componente `.tsx` ≤ 250 linhas | `actions.ts` ≤ 400 | lib `.ts` ≤ 350 | `route.ts` ≤ 200
- Cada `lib/<feature>/` expõe `index.ts` como API pública; consumidores importam só do index
- Arquivos `kebab-case`; componentes export `PascalCase`; hooks `use-x.ts`
- Sem `any` solto; sem default export em `lib/`

### Commits (Conventional obrigatório)
- Formato: `<type>(<scope>): <descrição em imperativo minúsculo>`
- Types: `feat | fix | refactor | test | docs | chore | perf | style | build | ci`
- A cada commit (rápido): `pnpm typecheck` zero erros + `pnpm lint` zero warnings + testes **afetados** verdes
- Antes do `git push` (gate único): `pnpm test:unit` 100% verde — não rodar a suíte inteira a cada commit

### Testes
- Toda feature nova tem teste correspondente (sem exceção)
- Unit: co-located (`foo.test.ts` ao lado de `foo.ts`)
- E2E: `tests/e2e/M<NN>-<slug>.spec.ts`

## Quality gate antes de PR

```bash
pnpm typecheck    # zero erros
pnpm lint         # zero warnings
pnpm test:unit    # 100% green
pnpm test:e2e     # 100% green
pnpm build        # sucesso
```

Ver checklist completo em `.skill/checklists/milestone-done.md`.
