# Delfos Site Builder — Convenções (Aider)

Stack: **Next.js 16 + Vercel + Neon + Drizzle + Tailwind v4 + shadcn/ui**.

## Workflow

Siga a fase atual do projeto. Leia o documento correspondente antes de implementar:

- Fase 0: `.skill/workflow/00-discovery.md`
- Fase 1: `.skill/workflow/01-design-system.md`
- Fase 2: `.skill/workflow/02-architecture.md`
- Fase 3: `.skill/workflow/03-master-plan.md`
- Fase 4: `.skill/workflow/04-execute-milestone.md`
- Fase 5: `.skill/workflow/05-launch-hardening.md`

Regras transversais (sempre ativas):
- `.skill/workflow/code-organization.md`
- `.skill/workflow/commit-discipline.md`

## Organização de código

- Estrutura por feature: `app/(area)/feature/` e `lib/feature/`
- Componente `.tsx` ≤ 250 linhas | `actions.ts` ≤ 400 | lib `.ts` ≤ 350 | `route.ts` ≤ 200
- `lib/<feature>/index.ts` expõe a API pública; consumidores importam só do index
- `import 'server-only'` em qualquer arquivo com DB ou secrets
- Zod em toda entrada externa (form, action arg, route body)
- Sem `any` solto; sem default export em `lib/`

## Commits

Conventional Commits obrigatório:
```
feat(M01-courses): adiciona CRUD de cursos no admin
fix(auth): corrige expiração de token de reset
test(M04): cobre os 6 tipos de exercício
```

Antes de cada commit: todos os testes passando, typecheck e lint zerados.

## Testes

- Toda feature nova tem teste (sem exceção)
- Unit: `foo.test.ts` ao lado de `foo.ts`
- E2E: `tests/e2e/M<NN>-<slug>.spec.ts`
- Failure modes cobertos: sem permissão → erro, anônimo → redirect, rate limit → 429
