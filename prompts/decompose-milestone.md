# Sub-prompt: decompose-milestone

Use ao gerar `MILESTONES/NN-<slug>.md` a partir do `PLAN.md` aprovado.

## Como invocar

Para cada milestone do `PLAN.md`, rodar com este contexto:

- BRIEF.md (produto)
- DESIGN_SYSTEM.md (UI)
- ARCHITECTURE.md (stack + decisões)
- Linha do milestone no PLAN.md (nome + critério de pronto resumido)

---

Você está decompondo este milestone em tasks acionáveis para um agente Claude implementar.

**Milestone:** {{NN}} — {{NAME}}
**Critério de pronto resumido:** {{DONE_SUMMARY}}
**Dependências:** {{DEPENDS_ON}}

Devolva o conteúdo de `MILESTONES/{{NN}}-{{SLUG}}.md` seguindo o template em [templates/MILESTONE.md.tpl](../templates/MILESTONE.md.tpl).

## Regras de decomposição

### 1. Critério de pronto **testável**

Cada item de "Critério de pronto" deve ser verificável por:
- Um teste E2E (fluxo de usuário) → escrito antes de implementar
- Um teste unit (cálculo, validação) → escrito antes de implementar
- Inspeção de arquivo (schema, página existe, redirect funciona)

❌ Errado: "feature funciona"
✅ Certo: "Admin acessa `/admin/courses/new`, preenche form com título e descrição, clica salvar, é redirecionado para `/admin/courses/[id]/edit` com curso criado no DB"

### 2. Tasks em ordem de execução

Ordene tasks de forma que cada uma desbloqueia a próxima. Sem "implementar tudo simultaneamente".

Subseções típicas:
- **Setup** — deps, configs, migrations
- **Schema/Data** — tabelas, indexes, seed
- **Server actions / API routes**
- **UI / pages / components**
- **Validação e segurança** — Zod, RBAC, rate limit
- **Testes**

### 3. Tasks atômicas

Uma task = uma mudança que cabe em ~3 a 30 linhas de código ou ~1 commit. Tasks gigantes ("implementar admin panel") são re-decompostas.

### 4. Testes obrigatórios

Mínimo:
- 1 unit test por função pura nova / validação Zod
- 1 E2E cobrindo o fluxo do critério de pronto
- 1 teste de "failure mode" se há permissões envolvidas

### 5. Decisões pendentes vão para ARCHITECTURE.md

Se aparecer uma decisão não-trivial durante a decomposição ("usar BlockNote ou Tiptap?"), **não crie task "Avaliar e escolher X"**. Pare e adicione a decisão em `ARCHITECTURE.md` como ADR-light antes de continuar.

### 6. Pré-requisitos do user

Algumas tasks só o user pode fazer (configurar Vercel env vars, comprar domínio, criar conta no Stripe). Liste-as em "Pré-requisitos do user" com marcador `**(usuário)**`.

### 7. Status com checkboxes granulares

Status final do milestone tem:
- [ ] Branch criada
- [ ] Testes do critério de pronto escritos e falhando (red)
- [ ] Implementação completa
- [ ] Testes do critério de pronto passando (green)
- [ ] Quality gate local passou
- [ ] PR aberto
- [ ] Aprovado pelo user
- [ ] Mergeado em main

### 8. Anti-padrões

- ❌ Tasks que são "vou pensar em X" — pesquisa não é task, é prep.
- ❌ Critério de pronto vago ("feature pronta").
- ❌ Tasks que envolvem decisão arquitetural — vão para `ARCHITECTURE.md`.
- ❌ Mais de 30 tasks num milestone — quebrar em dois milestones.
