# Disciplina de commit e testes (regra transversal)

> Não é uma fase. É **a regra mais inegociável** depois de "tests-first". Aplica em toda Fase 4 (execute-milestone). Toda feature implementada **termina** em commit verde, e nenhum commit acontece com teste vermelho.

## Regras absolutas

1. **Toda feature/regra de negócio nova → tem teste novo.** Sem exceção.
2. **Todo commit é Conventional Commit semântico.** Sem exceção.
3. **Commit acontece após cada feature implementada.** Não acumular feature + feature + commit gigante.
4. **Custo: rápido no commit, suíte completa no push.** Por commit roda só o **gate rápido** (`typecheck` + `lint` + testes **afetados**); a **suíte completa roda uma única vez antes do `git push`** (gate único). Antes era comum rodar a suíte inteira em todo commit **e** merge **e** push (3×/branch) — desperdício de tempo e de tokens de log. **Nunca dê push com a suíte vermelha.**
5. **Antes de commit que toca lógica:** `pnpm typecheck` + `pnpm lint` zero erros.
6. **Tests-first quando possível:** o teste do critério de pronto é escrito antes da implementação (TDD-leve — ver [prompts/tests-from-requirements.md](../prompts/tests-from-requirements.md)).
7. **Saída de teste enxuta:** rode a suíte com reporter compacto (`--reporter=dot --silent` no Vitest) nos gates automáticos — menos ruído de log no contexto da IA. Verboso só ao depurar uma falha.
8. **Agrupe tasks acopladas.** Uma branch por task é o padrão, mas quando 2-3 tasks são o **mesmo** trabalho (mesma refatoração/arquivo), agrupe numa branch só e cite-as no commit — menos rodadas de gate.

## Definição de "feature"

Uma feature é uma unidade de mudança que:
- Resolve **uma** task do `MILESTONES/<NN>-*.md` (ou um grupo coerente, ≤ 3 sub-tasks)
- Cabe em ~20-200 linhas de código novo/modificado
- Tem um teste correspondente
- Compila e passa em todos os testes existentes

Exemplos de "uma feature":
- ✅ Server action `createCourse` + validação Zod + teste
- ✅ Componente `<MagicLinkForm>` + teste de submissão
- ✅ Migration `add_email_verified_at` + tipo na schema
- ❌ "Implementei o admin panel inteiro" (10+ commits em 1)
- ❌ "Subi todos os endpoints de auth" (vire em 4-5 commits)

## Conventional Commits — formato obrigatório

```
<type>(<scope>): <descrição em minúsculas, presente, imperativo>

[corpo opcional explicando WHY]

[footer opcional: Refs #XX, Breaking Change, Co-Authored-By]
```

### Types permitidos

| Type | Quando usar |
|---|---|
| `feat` | Feature nova visível ao usuário |
| `fix` | Bugfix visível ao usuário |
| `refactor` | Reorganização sem mudança de comportamento |
| `test` | Adicionar/atualizar testes (sem código de feature) |
| `docs` | Só documentação (`.md`) |
| `chore` | Manutenção (deps, config, scripts) |
| `perf` | Melhoria de performance medida |
| `style` | Formatação, ponto-e-vírgula (sem mudança de lógica) |
| `build` | Build system, CI, Dockerfile |
| `ci` | Mudança em `.github/workflows/` |

### Scope (recomendado, não obrigatório)

Identifica a área/feature/milestone:
- `feat(M03): adiciona cálculo de progresso por trilha`
- `feat(auth): adiciona reset de senha`
- `feat(billing): integra Stripe webhook`
- `fix(M01-courses): corrige slug duplicado`
- `test(M04-exercises): cobre fluxo de drag-order`

Scope com `M<NN>` quando o trabalho é específico de um milestone — facilita rastrear PR depois.

### Descrição

- Imperativo presente: "adiciona", não "adicionado"
- Minúsculas no início
- Sem ponto final
- ≤ 72 caracteres na linha de título
- WHY no corpo se a mudança não é óbvia pelo título

### Exemplos bons

```
feat(M01-courses): adiciona CRUD de cursos no admin
feat(auth): adiciona reset de senha com TTL de 30min
fix(M05-org): corrige contagem de seats incluindo convites pendentes
refactor(lib/email): extrai client Resend pra módulo dedicado
test(M04): cobre os 6 tipos de exercício
docs(architecture): registra decisão de Markdown puro vs MDX
chore(deps): atualiza Next 16.0.1 → 16.0.2
perf(dashboard): paraleliza queries de progresso (340ms → 80ms)
```

### Exemplos ruins (rejeitar)

```
❌ updated stuff
❌ WIP
❌ feat: added thing
❌ fix bug
❌ Feat(M01): Added crud (capitalize errado, passado errado)
❌ feat(M01-courses): adiciona CRUD de cursos, corrige slug, atualiza testes, refatora schema  (commit gigante — quebrar)
```

## Fluxo de cada feature

Sequência obrigatória dentro de uma branch de milestone:

```
1. Identifica próxima task no MILESTONES/<NN>-*.md
2. Escreve teste(s) — devem falhar (red)
3. git add <test files>
4. git commit -m "test(<scope>): cobre <comportamento>"   # gate rápido: typecheck+lint+afetados
5. Implementa código mínimo para passar
6. pnpm typecheck  → zero erros
7. pnpm lint       → zero warnings
8. pnpm exec vitest run <arquivos afetados>  → verde (suíte completa fica para o push)
9. (se UI) snapshot light+dark+375+1440 conferido
10. git add <impl files>
11. git commit -m "feat(<scope>): <descrição>"   # gate rápido
12. Marca task como [x] no MILESTONES/<NN>-*.md
13. (loop) próxima task
--- ao fim da branch (antes do PR) ---
14. pnpm test:unit --reporter=dot --silent  → suíte COMPLETA 100% verde (gate único)
15. git push   (o gate de push roda a suíte completa por segurança)
```

### Variações aceitas

- **Passo 3-4 e 10-11 podem ser fundidos em 1 commit** se o teste e a implementação são pequenos e coesos:
  ```
  feat(M01-courses): adiciona createCourse server action + testes
  ```
  Use quando: ≤ 100 linhas no diff total, escopo claramente atômico.

- **Refactor sem mudança de comportamento** pode ser commit separado:
  ```
  refactor(lib/db): extrai queries de progresso pra módulo
  ```
  Mesmo nesse caso: testes têm que continuar passando.

## Bloqueios duros (não commitar se)

- [ ] **`pnpm test:unit` tem algum teste falhando** (mesmo testes antigos não relacionados — investigue antes)
- [ ] **`pnpm typecheck` retorna erros** (mesmo em código não tocado pelo diff)
- [ ] **A feature não tem teste** (toda feature/regra de negócio precisa)
- [ ] **Mensagem do commit não é Conventional**
- [ ] **Commit junta mudanças não relacionadas** (auth + content + email em 1 commit → quebra)

Se algum bloqueio dispara: **conserte o root cause**. Nunca:
- `--no-verify` para pular hook (já bloqueado pelos hooks)
- `eslint-disable` global pra passar lint
- `test.skip` em teste antigo "que estava quebrado antes"
- `// @ts-ignore` sem comentário explicando

## Teste existente quebrou após sua mudança — o que fazer

Sequência:

1. **Não pule.** Não comente `test.skip`. Não delete o teste.
2. Leia o teste. Ele captura uma regra de negócio que sua mudança quebrou?
   - **Sim, sua mudança está errada** → conserte o código novo
   - **Sim, mas a regra mudou intencionalmente** → atualize o teste **e o commit menciona a mudança** (corpo do commit explica o que mudou e por quê)
   - **Não, o teste estava frágil** → conserte o teste, NÃO delete (vire um teste melhor)
3. Commit:
   ```
   feat(M03): paywall agora libera membros de org

   Anteriormente apenas admin bypassava. Agora `canViewLockedContent`
   também aceita usuários em organização ativa (a org pagou pelos seats).

   Teste `access.test.ts > paywall blocks non-admin` virou
   `access.test.ts > paywall blocks anonymous and non-member` para
   refletir a regra atualizada.
   ```

## Testes obrigatórios por tipo de mudança

| Mudança | Teste mínimo |
|---|---|
| Função pura nova | Unit (Vitest) — caso feliz + edge + erro |
| Server action | Unit do happy path + failure (sem permissão, validação falha) |
| Schema Zod | Unit — accepts valid, rejects invalid (cobrir cada constraint) |
| Componente compartilhado (`components/<area>/`) | Unit (RTL) — render + interação principal |
| Componente local (`_components/`) | Coberto via E2E da página que usa |
| Server action que muda DB | Integration (Neon branch ou mock) — checa estado pós-mutação |
| Rota nova | E2E (Playwright) — fluxo do critério de pronto |
| Permissão / RBAC | Unit `requireRole` + E2E "anônimo → redirect" + E2E "wrong role → 403" |
| Rate limit | Unit do contador + E2E "Nth request → 429" |
| Webhook | Integration — signature válida → processa; inválida → 400; duplicata → noop |
| Cron job | Unit do handler + integration que valida side effects |
| Migration | Manual: aplicar em Neon dev branch, rodar query de validação |

## Anti-padrões a evitar

- ❌ Commit "WIP" em branch que vai virar PR (rebase squash antes do push pra remover)
- ❌ "Vou commitar quando o milestone fechar" — fica diff gigante, impossível de reverter parcialmente
- ❌ Commit que mistura `feat` + `refactor` + `test` (separa em 3)
- ❌ Mensagem do commit em inglês quando o resto do projeto é em português (ou vice-versa) — seja consistente
- ❌ Feature sem teste porque "é só uma mudança pequena"
- ❌ Pular `pnpm test:unit` porque "só mudei copy" — erros de tipo em copy também quebram
- ❌ `git add .` cego — sempre revisar `git status` e adicionar arquivos específicos
- ❌ Commitar arquivo de teste com `test.only` ou `test.skip` esquecido

## Como o Claude aplica isso

Em **toda Fase 4** (execute-milestone), antes de propor commit:

1. Confirma que escreveu teste para a mudança (se for nova feature/regra)
2. Roda `pnpm typecheck` + `pnpm lint` + os **testes afetados** (rápido) — espera verde
3. Compõe mensagem Conventional Commit com scope correto
4. Executa `git status` para revisar o que vai ser commitado
5. Faz `git add <files-específicos>` (sem `git add .` cego)
6. Faz `git commit` com a mensagem
7. Atualiza `MILESTONES/<NN>-*.md` marcando a task
8. **Antes do `git push`** (fim da branch): roda a **suíte completa** (`pnpm test:unit`) 100% verde

**Não pede aprovação do user para cada commit individual** (seria spam) — pede aprovação no PR, que agrega N commits do milestone.

**Pede aprovação do user** se: precisa skipar/atualizar teste antigo, precisa marcar feature como "WIP" e parar no meio, ou se um quality gate falha de forma que vai exigir trade-off.
