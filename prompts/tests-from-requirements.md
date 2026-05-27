# Sub-prompt: tests-from-requirements

Use **antes de implementar** cada milestone. Converte cada item do "Critério de pronto" em testes concretos (Vitest unit + Playwright E2E).

## Workflow

1. Abrir `MILESTONES/NN-*.md` ativo.
2. Para cada item de "Critério de pronto", gerar testes.
3. Comitar testes antes de implementar (red phase).
4. Implementar até virarem verde.

## Mapeamento

| Tipo de requisito | Tipo de teste | Local |
|---|---|---|
| Função pura, cálculo, validação | Unit (Vitest) | `lib/foo.test.ts` ao lado do código |
| Schema / Zod validation | Unit (Vitest) | `lib/validation/foo.test.ts` |
| Fluxo de usuário (cliques, redirecionamento, form) | E2E (Playwright) | `tests/e2e/<feature>.spec.ts` |
| Permissão / RBAC | E2E + Unit | E2E para "anônimo redirect"; Unit para `requireRole` |
| Server action mutation | Integration (Vitest com DB mock ou Neon branch) | ao lado do action |
| Webhook | Integration | `tests/integration/webhooks/<name>.test.ts` |

## Template Vitest unit

```ts
import { describe, it, expect } from 'vitest';
import { fn } from './fn';

describe('fn', () => {
  it('case feliz', () => {
    expect(fn('input válido')).toBe('output esperado');
  });

  it('rejeita input inválido', () => {
    expect(() => fn('')).toThrow(/expected/);
  });

  it('edge case: <descrição>', () => {
    expect(fn('edge')).toEqual({ ... });
  });
});
```

## Template Playwright E2E

```ts
import { test, expect } from '@playwright/test';

test.describe('M<NN> — <nome do milestone>', () => {
  test('critério de pronto: <requisito>', async ({ page }) => {
    await page.goto('/');
    await page.getByRole('link', { name: /entrar/i }).click();
    await expect(page).toHaveURL(/\/login/);

    await page.getByLabel('Email').fill('test@example.com');
    await page.getByLabel('Senha').fill('senhaForte123');
    await page.getByRole('button', { name: /entrar/i }).click();

    await expect(page).toHaveURL(/\/dashboard/);
    await expect(page.getByRole('heading', { name: /seu progresso/i })).toBeVisible();
  });

  test('failure mode: usuário sem permissão é redirecionado', async ({ page }) => {
    await page.goto('/admin');
    await expect(page).toHaveURL(/\/login/);
  });
});
```

## Regras

1. **Todo critério de pronto vira ≥ 1 teste.** Sem exceções.
2. **Failure modes obrigatórios** quando há permissões/billing/rate limit:
   - Anônimo em rota protegida → redirect
   - Não-admin em action de admin → erro
   - 6º request em rate limit → 429
3. **Não testar implementação interna.** Testar comportamento observável (input → output, fluxo → estado final).
4. **Tests devem falhar inicialmente.** Se passam antes de implementar, ou (a) o teste está mockando demais, ou (b) a feature já existe e o critério de pronto está mal escrito.
5. **Commit antes de implementar:**
   ```bash
   git add tests/ lib/**/*.test.ts
   git commit -m "test(M<NN>): testes do critério de pronto"
   ```
6. **Não pular tests.** Se Vitest ou Playwright não está configurado no projeto, esse é o primeiro item do M00-bootstrap, não um obstáculo desta fase.

## Anti-padrões

- ❌ Testes que mockam tudo e validam só que o mock foi chamado
- ❌ Snapshot tests para tudo (frágeis em UI)
- ❌ "Vou escrever testes depois"
- ❌ Test que duplica a implementação (testa o exato código que executa)
- ❌ Skip teste flake — investigar root cause
