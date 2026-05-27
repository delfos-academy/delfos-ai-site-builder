# Quality Gates

Lista exaustiva dos gates que **bloqueiam progresso**. Cada gate tem comando ou checklist. Não tem "talvez" — é binário.

## Por fase

### Gate 0 → 1 (Discovery → Design System)

- [ ] `BRIEF.md` cobre as 8 perguntas e foi confirmado pelo user
- [ ] `REFERENCES.md` tem ≥ 1 referência com "tirar" e "não copiar"

### Gate 1 → 2 (Design System → Architecture)

- [ ] `DESIGN_SYSTEM.md` cobre 8 seções (ver [checklists/design-system-done.md](../checklists/design-system-done.md))
- [ ] Tokens HSL aplicados em `app/globals.css`
- [ ] Snapshot visual em light + dark mostrado e aprovado pelo user
- [ ] Zero gradiente / blur-glow / icon-chip / Inter

### Gate 2 → 3 (Architecture → Master Plan)

- [ ] `ARCHITECTURE.md` lista stack locked + decisões + diagrama
- [ ] `CLAUDE.md` instanciado no projeto-alvo

### Gate 3 → 4 (Master Plan → Execute)

- [ ] `PLAN.md` ≤ 200 linhas, aprovado pelo user
- [ ] 6–10 milestones, cada um com critério de pronto **testável**
- [ ] `WORKFLOW.md` cobre branch/PR/merge

### Gate antes de cada PR (Milestone)

Ver [checklists/milestone-done.md](../checklists/milestone-done.md). Resumo:

**Comandos** (todos devem passar):
```bash
pnpm typecheck    # zero erros
pnpm lint         # zero warnings
pnpm test:unit    # 100% green
pnpm test:e2e     # 100% green
pnpm build        # sucesso
```

**Verificações:**
- [ ] Todos os requisitos do critério de pronto do milestone têm teste correspondente verde
- [ ] Branch correto (`feat/M<NN>-slug`)
- [ ] Commits seguindo Conventional Commits
- [ ] `MILESTONES/NN-*.md` atualizado com `- [x]` nas tasks
- [ ] Screenshot anexado no PR se mudou UI
- [ ] Skill `security-review` rodada se tocou em auth/billing/dados sensíveis
- [ ] Skill `verify` rodada se mudou UI significativa
- [ ] **Checklist [code-organization.md](../checklists/code-organization.md) passa** (tamanhos, JSDoc, public API, sem `any` solto, sem default export em `lib/`)

### Gate de Launch (Fase 5)

Ver [checklists/launch-ready.md](../checklists/launch-ready.md). Resumo:

- [ ] Lighthouse ≥ 95 em landing/login/dashboard/conteúdo (mobile + desktop)
- [ ] Zero secrets em client bundle
- [ ] Rate limit testado em endpoint de auth (6º request retorna 429)
- [ ] CSP sem violações em browser console
- [ ] Sentry recebeu erro de teste em prod
- [ ] Páginas LGPD publicadas (`/privacy`, `/terms`)
- [ ] Endpoint `/api/me/export` testado
- [ ] Delete account testado (cria tombstone, apaga FKs em cascade)

## Por categoria

### TypeScript / Lint

```bash
pnpm typecheck   # tsc --noEmit; 0 errors
pnpm lint        # eslint; 0 warnings (warn vira error em CI)
```

`tsconfig.json` precisa ter:
```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitOverride": true
  }
}
```

### Testes

- **Unit (Vitest)**: tudo que é função pura, validação Zod, cálculo, helper.
- **E2E (Playwright)**: pelo menos 1 spec por milestone cobrindo o fluxo do critério de pronto.
- **Smoke**: cada página crítica renderiza sem 500.
- **Tests of failure modes** quando o milestone envolve auth/permissions/billing:
  - Rota protegida sem session → redirect
  - Action de admin chamada por não-admin → erro
  - Webhook Stripe com signature inválida → 400

### Segurança em PR sensível

Se o PR toca em qualquer um destes, é **obrigatório** chamar skill `security-review`:

- `lib/auth/**`
- `app/api/auth/**`
- `app/api/stripe/**`
- `lib/billing/**`
- `proxy.ts` (Next 16 middleware)
- `lib/db/schema.ts`
- `lib/email/**`
- `next.config.ts` (CSP/headers)

### UI/UX em PR visual

Se o PR muda pelo menos uma tela:

- [ ] Screenshot light + dark anexado
- [ ] Testado em 375px e 1440px
- [ ] Sem violação dos do/don't do `DESIGN_SYSTEM.md` (sem gradiente, sem blur-glow, sem Inter, etc)
- [ ] Skill `verify` rodada (abre o app, executa o fluxo)

### Performance em PR de página crítica

Se o PR adiciona/altera landing/login/dashboard:

- [ ] Lighthouse rodado, score ≥ 95 (ou explicar regression)
- [ ] LCP < 2.5s, INP < 200ms, CLS < 0.1

## Como falhar um gate

Se um gate falha, **não prossiga**. Opções:

1. Voltar e corrigir.
2. Se o gate não faz sentido para esta PR, registrar a justificativa no PR description em uma seção `## Quality gate exceptions` e pedir aprovação explícita do user.

Nunca silenciosamente pular.

## Anti-padrões

- ❌ "Os testes passam local mas vou rodar de novo em CI". Sempre rodar local antes.
- ❌ "Vou consertar o lint depois". Não.
- ❌ "É só um typo no .md, não preciso de gate". Toda PR passa por gate.
- ❌ Adicionar `eslint-disable` para passar o gate. Conserta o código.
- ❌ Rodar `pnpm test:e2e -- --grep "X"` (subset). Todo o E2E roda.
