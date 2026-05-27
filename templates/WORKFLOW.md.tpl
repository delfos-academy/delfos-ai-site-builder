# {{PROJECT_NAME}} — Workflow de Desenvolvimento

> Regras de branch, PR, merge e revisão. Aplicável a humanos e ao Claude.

## Branches

- **`main`** — produção. Deploy automático via Vercel. Protegida no GitHub (CI obrigatório, no direct push em prod).
- **`feat/M<NN>-<slug>`** — uma branch por milestone do `PLAN.md`. Ex: `feat/M03-progress-engine`.
- **`fix/<short-desc>`** — bugfix isolado.
- **`chore/<short-desc>`** — manutenção (deps, configs).

> Naming inclui o número do milestone (`M03`) pra rastrear qual macro-etapa do plano a branch endereça.

## Commits

Conventional Commits obrigatório.

- `feat(M<NN>): adiciona <X>` — feature nova
- `fix: corrige <X>` — bugfix
- `refactor: <X>` — sem mudança de comportamento
- `test: <X>` — só testes
- `docs: <X>` — só docs
- `chore: <X>` — manutenção
- `style: <X>` — só formatação/cor (sem mudança de lógica)

Granular > monolítico. Cada commit deve compilar e passar typecheck.

## Pull Requests

### Quando abrir

Quando o milestone estiver com todos os critérios de pronto verdes + quality gate local passou.

### Template de PR

```md
## Summary
- <bullet 1>
- <bullet 2>

## Critério de pronto (M<NN>)
- [x] <requisito 1>
- [x] <requisito 2>

## Test plan
- [ ] Unit: `pnpm test:unit`
- [ ] E2E: `pnpm test:e2e`
- [ ] Manual: <passos>

## Screenshots
<antes/depois ou só "depois" — light + dark + mobile>

## Quality gate exceptions (se houver)
<justificativa caso algum gate tenha sido pulado>

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

### Revisão

- Owner do PR: o autor (Claude ou humano).
- Reviewer: o user (founder/product owner) é o reviewer único no V0.
- **Sem auto-merge.** Claude **nunca** faz `gh pr merge` sem aprovação explícita do user na sessão.

### Merge

- Estratégia: **squash merge** (histórico limpo em `main`).
- Delete branch após merge.
- Comando:
  ```bash
  gh pr merge --squash --delete-branch
  ```

## Quality Gate antes de cada merge

Lista canônica: [quality-gates.md da skill](https://github.com/<org>/delfos-ai-site-builder/blob/main/workflow/quality-gates.md). Resumo:

```bash
pnpm typecheck   # zero erros
pnpm lint        # zero warnings
pnpm test:unit   # 100% green
pnpm test:e2e    # 100% green
pnpm build       # sucesso
```

Mais skills auxiliares dependendo do escopo do PR — ver [04-execute-milestone.md §7](https://github.com/<org>/delfos-ai-site-builder/blob/main/workflow/04-execute-milestone.md).

## Hooks (automação local)

Settings em `.claude/settings.json` — exemplo em [hooks/settings.json.example](https://github.com/<org>/delfos-ai-site-builder/blob/main/hooks/settings.json.example).

- `PostToolUse` em Edit/Write sobre `.ts/.tsx` → roda `pnpm typecheck` no arquivo
- `PostToolUse` em Edit/Write → roda `pnpm lint --fix` no arquivo
- `Stop` → checa se há mudanças não-commitadas e avisa

## Branch protection (GitHub — setup manual do user)

Configurar em `Settings > Branches > main`:

- [x] Require pull request before merging
- [x] Require status checks to pass:
  - CI: typecheck
  - CI: lint
  - CI: test:unit
  - CI: build
- [x] Do not allow bypassing
- [ ] Require approvals — desligado no V0 (revisor é o user, sem outros devs)

## Deploy

- Branch (`feat/*`) push → Vercel preview deploy + Neon branch automática.
- Merge em `main` → deploy de produção.
- Rollback: `vercel rollback <deployment-id>` ou revert do commit.

## Quando algo dá ruim em produção

1. Identificar via Sentry / Vercel Analytics.
2. Hotfix branch: `fix/<curto>`.
3. PR direto pra `main` com mesmo quality gate.
4. Se for crítico, considerar `vercel rollback` enquanto fix é preparado.
5. Postmortem em `docs/postmortems/YYYY-MM-DD-<slug>.md`.

## Anti-padrões

- ❌ Push direto em `main` (mesmo Claude pode, mas **não deve** sem aviso prévio do user).
- ❌ Merge sem aprovação do user.
- ❌ `--no-verify` ou pular pre-commit hooks.
- ❌ Commits gigantes "fix everything".
- ❌ Branch que vive > 1 milestone (deve ser mergeada e descartada).
