# {{PROJECT_NAME}} — Backlog

> Features pós-V0. Não está no escopo dos milestones do `PLAN.md`. "Boa ideia, mas depois" vem para cá.

## Como usar

Cada feature deve ter:
- Contexto (1-2 linhas)
- User value (por que importa)
- Complexidade (S/M/L/XL)
- Risco (baixo/médio/alto)

Toda PR que descobre uma "by the way, seria legal X" adiciona aqui em vez de fazer no PR atual.

Manter número manageable (≤ 50). Arquivar descartadas em `BACKLOG_ARCHIVE.md`.

## Categorias

### 1. Engajamento & retenção
- {{ENGAGEMENT_IDEAS}}

### 2. Conteúdo & autoria
- {{CONTENT_IDEAS}}

### 3. Internacionalização (pós-V0)
- Adicionar EN (catalog separado do PT, como decidido)
- Mecanismo de tradução assistida por LLM com revisão humana
- RTL support para futuras adições

### 4. Mobile
- PWA com offline reading
- App nativo (React Native / Expo) — avaliar quando MAU > 10k
- Push notifications

### 5. Integração corporativa (se B2B)
- SSO SAML (WorkOS quando enterprise pedir)
- SCIM (provisioning automático)
- Webhooks para sistemas internos do cliente
- Reports exportáveis (CSV, PDF) por org

### 6. Vendas & marketing
- {{SALES_IDEAS}}

### 7. Analytics avançado
- Dashboard com funnel
- Cohort retention
- Predictive churn

### 8. AI features
- {{AI_FEATURE_IDEAS}}

### 9. Acessibilidade avançada
- Audio descrição
- Transcrições completas
- Versão "high contrast" extra

### 10. Operações & growth
- Affiliate program
- Customer success automation
- NPS tracking
- Churn survey

## Quarterly review

A cada quarter, founder + Claude revisam:
- Top 5 candidatos → próximo ciclo de milestones
- Itens descartados → `BACKLOG_ARCHIVE.md`
- Adicionar insights de customer interviews
