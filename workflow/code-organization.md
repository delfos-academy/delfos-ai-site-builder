# Regras de organização de código (transversal)

> Não é uma fase. É uma regra **contínua** aplicada em toda Fase 4 (execute milestone) e validada no `pre-merge-review`. O objetivo é que:
>
> - Cada arquivo seja **pequeno o suficiente** pro Claude ler inteiro sem encher contexto
> - Cada módulo tenha **uma responsabilidade clara**
> - Humano consiga **achar e editar** algo pontual sem ler o resto do projeto
> - Tooling (LSP, grep) **encontre o que está procurando** sem mágica

## Limites duros

| Tipo | Soft (avisar) | Hard (refatorar) |
|---|---|---|
| Componente React (`.tsx`) | 150 linhas | 250 linhas |
| Server action (`actions.ts`) | 200 linhas | 400 linhas |
| Lib function module (`*.ts`) | 200 linhas | 350 linhas |
| Route handler (`route.ts`) | 100 linhas | 200 linhas |
| Schema (`schema.ts`) | 500 linhas | 800 linhas (depois quebrar por domínio) |
| Test file | 300 linhas | 500 linhas |

> **Exceção:** `lib/db/schema.ts` pode crescer mais porque Drizzle quer schema único — mas SECCIONE com `// ===== Users =====` etc, e quando passar de 800 linhas, quebre em `schema/users.ts`, `schema/content.ts` e re-exporte.

Quando soft é atingido: avisar no PR ("componente X tem 180 linhas — vale considerar quebrar").
Quando hard é atingido: **bloqueio**. Refatorar antes do merge.

## Estrutura de pastas (Next.js App Router)

Padrão **por feature**, não por tipo.

```
app/
├── (marketing)/                     route group: site público
│   ├── layout.tsx
│   ├── page.tsx
│   └── pricing/
│       └── page.tsx
├── (auth)/                          login, signup, reset
├── (app)/                           área autenticada do user final
│   ├── layout.tsx
│   ├── dashboard/
│   │   └── page.tsx
│   └── <feature>/                   ex: courses, lessons
│       ├── page.tsx
│       ├── actions.ts               server actions desta feature
│       └── _components/             componentes só usados aqui (prefixo _)
│           └── feature-thing.tsx
└── (admin)/                         área de admin

components/
├── ui/                              shadcn primitives + variantes (botão, input)
├── brand/                           logo, wordmark
├── auth/                            forms de login/signup (compartilhados)
├── marketing/                       hero, value-props, footer
└── <feature>/                       componentes compartilhados entre páginas da feature

lib/
├── db/
│   ├── index.ts                     Drizzle client
│   ├── schema.ts                    (ou pasta schema/ se grande)
│   └── seed.ts
├── auth/
│   ├── index.ts                     barrel: re-exporta o público
│   ├── session.ts
│   ├── password.ts
│   ├── token.ts
│   └── *.test.ts                    co-located
├── email/
│   ├── send.ts
│   ├── resend.ts
│   └── templates/                   React Email templates JSX
├── validation/                      Zod schemas
│   ├── auth.ts
│   ├── content.ts
│   └── *.test.ts
├── <feature>/                       lógica de domínio por feature
└── placeholders/                    dados estáticos (company, pricing)

tests/
├── e2e/                             Playwright
├── mocks/                           mocks de vendors
└── helpers/                         utilities compartilhados

scripts/                             scripts utilitários (capture-reference, apply-migration)
docs/
├── decisions/                       ADRs
├── incidents/
└── postmortems/
```

## Regras por tipo de arquivo

### Componentes React

- **Uma exportação padrão por arquivo** quando é componente "principal" da pasta.
- Sub-componentes só usados internamente: arquivo separado com export nomeado, **dentro de `_components/`** se forem locais a uma página App Router.
- Props sempre tipadas com `interface ComponentNameProps`, declarada acima do componente.
- Sem props "boolean grandes" — `<Button primary danger small loading disabled />` vira `variant: "primary" | "danger"` + `size: "sm"`.
- `'use client'` no topo SÓ se realmente precisa de interatividade. Default é RSC.

```tsx
// ✅ Bom — pequeno, tipado, foco único
interface CertificateBadgeProps {
  title: string;
  issuedAt: Date;
  verifyToken: string;
}

export function CertificateBadge({ title, issuedAt, verifyToken }: CertificateBadgeProps) {
  return (
    <article className="rounded-lg bg-card p-4">
      <h3 className="font-display text-lg">{title}</h3>
      <time className="num text-muted">{issuedAt.toLocaleDateString('pt-BR')}</time>
      <a href={`/verify/${verifyToken}`}>Verificar</a>
    </article>
  );
}
```

### Server actions

- Um arquivo `actions.ts` por route segment, no máximo.
- Cada action exportada **começa com `'use server'`** (ou o arquivo inteiro).
- **Cada action é uma função nomeada exportada** — sem default export.
- Validação Zod **na primeira linha** do corpo. Sem exceção.
- `requireUser()` / `requireAdmin()` antes de tocar DB.

```ts
// app/(admin)/admin/courses/actions.ts
'use server';

import { z } from 'zod';
import { requireAdmin } from '@/lib/auth/session';
import { db } from '@/lib/db';
import { courses } from '@/lib/db/schema';
import { courseInputSchema } from '@/lib/validation/content';
import { revalidatePath } from 'next/cache';

/**
 * Cria um novo curso em estado `draft`.
 * Apenas admins com role `content_admin` ou superior.
 */
export async function createCourse(input: z.infer<typeof courseInputSchema>) {
  const data = courseInputSchema.parse(input);
  const admin = await requireAdmin('content_admin');
  const [course] = await db.insert(courses).values({ ...data, createdBy: admin.id }).returning();
  revalidatePath('/admin/courses');
  return course;
}
```

### Lib modules

- Cada `lib/<feature>/` tem um `index.ts` que **re-exporta a "API pública"** do módulo. Resto dos arquivos é detalhe interno.
- Exporta o **mínimo** necessário. Função/tipo interno fica sem export.
- JSDoc obrigatório em **toda função exportada** (ver próxima seção).

```ts
// lib/auth/index.ts (public API)
export { getSession, requireUser, requireAdmin } from './session';
export { hashPassword, verifyPassword } from './password';
export { hashToken } from './token';
export type { Session } from './session';
// password-reset, email-verification são chamados de dentro do lib;
// se quiser expor, adiciona aqui explicitamente
```

Em outros lugares, sempre importar de `@/lib/auth`, nunca de `@/lib/auth/session` direto. Isso permite refatorar interno sem quebrar consumidores.

### Schema

- Um único arquivo `lib/db/schema.ts` enquanto < 800 linhas.
- Seccionar com comentários:
  ```ts
  // ===== Users & Sessions =====
  export const users = pgTable(...);
  export const authSessions = pgTable(...);

  // ===== Content =====
  export const courses = pgTable(...);
  ```
- Acima de 800 linhas: quebrar em `lib/db/schema/users.ts`, `schema/content.ts`, etc, e `schema/index.ts` re-exporta.
- **Toda tabela tem JSDoc no topo** explicando o propósito.

### Tests

- Co-located: `foo.test.ts` ao lado de `foo.ts` para unit tests.
- E2E em `tests/e2e/M<NN>-*.spec.ts` (prefixo por milestone).
- Helpers compartilhados em `tests/helpers/` — não duplicar setup auth em cada spec.

## JSDoc — onde é obrigatório

JSDoc não em todo lugar — só nas **superfícies públicas**:

1. **Todo `export` em `lib/<feature>/index.ts`** (a API pública do módulo).
2. **Toda server action** exportada.
3. **Todo componente exportado de `components/`** (ou seja, componentes compartilhados; em `_components/` interno é opcional).
4. **Todo tipo exportado** que não é trivial (ex: `Session`, `RBACRole`).
5. **Migrations** complexas em `lib/db/schema.ts` ou `drizzle/*.sql` quando há lógica não-óbvia.

Formato mínimo:

```ts
/**
 * <O que faz em uma linha>.
 *
 * <Detalhes opcionais — quando usar, limitações, side effects.>
 *
 * @param input - <descrição se não óbvia>
 * @returns <descrição do retorno se não óbvia>
 * @throws {Error} se <condição não esperada>
 */
export async function foo(input: FooInput): Promise<Foo> { ... }
```

Não escrever JSDoc óbvio:

```ts
// ❌ Lixo — repete o que o tipo já diz
/**
 * @param user - the user
 * @returns the user's name
 */
function getName(user: User): string { ... }

// ✅ Ou JSDoc útil, ou nenhum
/**
 * Resolve o display name considerando: name → email → "Usuário".
 * Usado em header e em emails — manter consistente.
 */
function getName(user: User): string { ... }
```

## Naming

- **Arquivos:** `kebab-case.ts` (não `camelCase.ts`, não `PascalCase.ts`).
- **Componentes:** export em `PascalCase`, mas arquivo em `kebab-case.tsx` (ex: `magic-link-form.tsx` exporta `MagicLinkForm`).
- **Hooks:** `use-x.ts` exporta `useX`.
- **Tipos:** `PascalCase`. Suffix `Props` para props de componente; `Input` / `Output` para schemas Zod; nenhum prefixo `I` (não fazemos C#).
- **Constantes:** `UPPER_SNAKE_CASE` para top-level constants públicas.
- **Booleans:** prefixo `is`/`has`/`can`/`should`.
- **Funções server-only:** sem prefixo especial. Mas o `import 'server-only'` no topo do arquivo é obrigatório se manipula DB/secret.

## Imports

Ordem (auto-fix via ESLint plugin `simple-import-sort`):

```ts
// 1. side-effect imports
import 'server-only';

// 2. node:* built-ins
import { readFile } from 'node:fs/promises';

// 3. external packages
import { z } from 'zod';
import { redirect } from 'next/navigation';

// 4. internal (path alias @/)
import { db } from '@/lib/db';
import { requireUser } from '@/lib/auth';

// 5. relative
import { helper } from './helper';

// 6. type-only
import type { Session } from '@/lib/auth';
```

- Sempre `import type` quando importa só tipos.
- Sempre `@/...` para internos, **nunca** `../../../lib/db`.
- Importar de barrel/index mesmo quando só usa uma coisa? — **sim, importe do index**. A consistência ganha do micro-perf.
- Exceção: `lucide-react` (tree-shaking quebra com barrel) — importar individual: `import { Check } from 'lucide-react'` é OK pq o lucide próprio é tree-shake-friendly.

## Comentários

Repete o que `CLAUDE.md` já diz:

- Não comentar o **WHAT** — o código já diz.
- Comentar o **WHY** não-trivial: regra de negócio, workaround, decisão temporal.
- TODOs **devem** ter dono ou issue: `// TODO(M05): substituir por Upstash quando escalar`.
- Sem `console.log` esquecido. Use `logger` (Sentry breadcrumb) se for debug em prod.

## Hard "não":

- ❌ **Default exports** em lib (componentes podem). Atrapalham refactor/rename automático.
- ❌ **Funções com > 5 parâmetros posicionais.** Vire objeto: `foo({ a, b, c, d, e })`.
- ❌ **Aninhamento > 4 níveis.** Extraia função.
- ❌ **`any` solto.** Use `unknown` + narrow, ou tipe corretamente.
- ❌ **`// @ts-ignore` / `// @ts-expect-error`** sem comentário explicando.
- ❌ **Magic numbers / strings** em código de negócio. Vira constante nomeada.
- ❌ **`process.env.X` espalhado.** Lê uma vez em `lib/env.ts` (tipado via Zod), exporta `env`.

## Checklist no pre-merge

Adicionado a [checklists/code-organization.md](../checklists/code-organization.md). Roda no `pre-merge-review` em todo PR.

## Ferramentas automatizadas (configurar no projeto-alvo)

- **ESLint** com `eslint-plugin-import`, `simple-import-sort`, `eslint-plugin-jsdoc`.
- **Tamanho de arquivo:** [`eslint-plugin-filesize`](https://www.npmjs.com/package/eslint-plugin-file-progress) ou regra custom contando linhas — alerta soft no editor.
- **Knip** (`knip`) — detecta exports e arquivos não usados. Rodar quarterly.
- **ts-prune** — exports mortos.
- **Husky + lint-staged** — pre-commit roda eslint + prettier no que mudou.

Quais ativar: ver `MILESTONES/00-bootstrap.md` (deve incluir setup desses).
