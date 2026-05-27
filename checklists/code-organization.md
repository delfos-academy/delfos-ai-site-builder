# Checklist — Organização de código

Aplicado em **todo PR** (parte do `pre-merge-review`). Bloqueia merge se algo cair em "hard limit".

## Tamanhos

- [ ] Nenhum componente `.tsx` com > 250 linhas (hard). Avisar se > 150.
- [ ] Nenhum `actions.ts` com > 400 linhas (hard). Avisar se > 200.
- [ ] Nenhum lib `.ts` com > 350 linhas (hard). Avisar se > 200.
- [ ] Nenhum `route.ts` com > 200 linhas (hard). Avisar se > 100.
- [ ] `schema.ts` < 800 linhas ou já seccionado em pasta `schema/`

> Comando rápido pra checar (rodar no diff):
> ```bash
> git diff --name-only main...HEAD | xargs -I{} wc -l {} 2>/dev/null | sort -rn | head -20
> ```

## Estrutura

- [ ] Arquivo novo está na pasta certa (`app/` por rota, `lib/` por domínio, `components/` por uso)
- [ ] Componente compartilhado em `components/<area>/`; componente de uma página em `_components/` ao lado da página
- [ ] Server action em `actions.ts` ao lado da rota, não em pasta solta
- [ ] Test co-located (`foo.test.ts` ao lado de `foo.ts`) para unit; E2E em `tests/e2e/`

## Naming

- [ ] Arquivos `kebab-case.ts` / `kebab-case.tsx`
- [ ] Componentes export `PascalCase`
- [ ] Hooks `use-<thing>.ts` exportando `useThing`
- [ ] Booleans com prefixo `is/has/can/should`
- [ ] Sem prefixo `I` em interfaces

## Imports

- [ ] Imports ordenados (side-effect → node → external → `@/` → relativo → type-only)
- [ ] Usa `@/...` para internos (sem `../../../`)
- [ ] `import type` quando só tipos
- [ ] Importa de barrel `@/lib/<feature>` quando possível
- [ ] `lucide-react` importado individual (`import { Check } from 'lucide-react'`)

## Public API por módulo

- [ ] Cada `lib/<feature>/` tem `index.ts` que re-exporta a API pública
- [ ] Consumidores importam do `index` (não de arquivo interno)
- [ ] Funções/tipos internos **não exportados** (ou pelo menos não do index)

## JSDoc obrigatório

- [ ] Toda exportação em `lib/<feature>/index.ts` tem JSDoc
- [ ] Toda server action tem JSDoc (o que faz + quem pode chamar)
- [ ] Todo componente em `components/` (compartilhado) tem JSDoc
- [ ] Todo tipo exportado não-trivial tem JSDoc
- [ ] JSDoc não é óbvio (não repete tipos)

## Server-only

- [ ] `import 'server-only'` no topo de arquivos que tocam DB/secrets/vendor APIs
- [ ] Sem secret em código que roda no client (verificado)

## Code smells (bloqueio)

- [ ] Sem `any` solto (usa `unknown` + narrow, ou tipo correto)
- [ ] Sem `@ts-ignore`/`@ts-expect-error` sem comentário explicando
- [ ] Sem `console.log` esquecido
- [ ] Sem default export em `lib/`
- [ ] Sem função com > 5 parâmetros posicionais (vira objeto)
- [ ] Sem aninhamento > 4 níveis
- [ ] Sem TODO sem dono/issue
- [ ] Sem magic numbers/strings em negócio (vira const nomeada)

## Validação Zod

- [ ] Toda entrada externa nova (form, action arg, route body) validada com Zod
- [ ] Schema Zod em `lib/validation/<area>.ts`, não inline na action

## Dead code (rodar quarterly, não obrigatório por PR)

- [ ] `npx knip` — sem exports não usados nas mudanças
- [ ] `npx ts-prune` — sem exports mortos

## Documentação

- [ ] Se adicionou conceito novo (entity, role, fluxo), atualizado em `ARCHITECTURE.md`
- [ ] Se decidiu algo não-trivial, ADR-light em `MILESTONES/NN-*.md` §"Decisões registradas"
- [ ] Se mudou public API de um módulo, atualizado o `index.ts` e o JSDoc

## Anti-padrões a flagar

- ❌ Componente "manager" que faz tudo (separa em sub-componentes)
- ❌ Utility com 30 funções não relacionadas (`utils.ts` virou lixão — separa por área)
- ❌ Server action que chama outra server action (cadeia confusa — refatora pra lib function)
- ❌ Import circular (eslint pega: `import/no-cycle`)
- ❌ Pasta `helpers/` solta sem dono claro (todo helper pertence a um domínio)
