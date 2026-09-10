# Núcleo universal de aceite técnico

Estas regras são critérios obrigatórios para análise, revisão, sugestão e
geração de código em qualquer linguagem ou projeto. Elas não são exemplos nem
uma lista opcional. Nenhum resumo, prompt da tarefa ou regra de stack substitui
este núcleo ou os módulos detalhados aplicáveis.

O catálogo completo foi preservado em
`~/development/ai-config-personal/references/technical-acceptance/catalog.md`.
Ele fica fora de `rules/` para não entrar integralmente no contexto de todas as
sessões.

## Aplicação obrigatória

Antes de atuar sobre código:

1. entenda o pedido, os arquivos envolvidos, a arquitetura existente e o fluxo
   completo afetado;
2. aplique integralmente este núcleo;
3. identifique no roteamento abaixo todos os módulos relacionados aos arquivos,
   camadas, comportamentos e riscos do trabalho;
4. leia integralmente as respectivas seções do catálogo antes de analisar,
   sugerir, revisar ou gerar código;
5. aplique também as regras da stack e as instruções locais do projeto;
6. quando houver dúvida razoável sobre a relevância de um módulo, inclua-o.

Seleção por relevância reduz contexto, não rigor. Não use o carregamento
seletivo para ignorar riscos indiretos, efeitos colaterais ou consumidores do
fluxo alterado. Uma tarefa pode exigir vários módulos.

Ao concluir uma etapa, confronte as linhas reais alteradas com este núcleo e
reabra as seções aplicáveis do catálogo, conforme o gate definido em
`AGENTS.md`.

## Roteamento dos módulos detalhados

Leia no catálogo todas as seções indicadas pelos gatilhos aplicáveis:

- **Aplicação, evidência e escopo:** `Propósito e modo de uso` e `Critérios de
  aplicação e aceite`. Obrigatório em análises técnicas, decisões de solução e
  mudanças com possível quebra de contrato, migração, refatoração ou risco
  operacional.
- **Qualidade geral e comentários:** `Regras gerais` e `Comentários no código`.
  Obrigatório ao criar ou alterar código, testes, comentários, docblocks ou
  docstrings.
- **Arquitetura e domínio:** `Arquiteturas e padrões que devem ser considerados`,
  `Backend — arquitetura e design` e `Domínio e regras de negócio`. Obrigatório
  para mudanças em services, use cases, controllers, módulos, entidades,
  policies, adapters, repositories ou responsabilidades entre camadas.
- **Segurança e isolamento:** `Multi-tenancy`, `Segurança` e `Autenticação e
  autorização`. Obrigatório quando houver identidade, permissões, ownership,
  IDs vindos do cliente, dados sensíveis, tenant, sessão, token, upload,
  webhook ou endpoint exposto. Inclua sempre que existir risco de IDOR.
- **Consistência, contratos e dados:** `Transações e consistência`, `DTOs,
  contratos e validação`, `Banco de dados` e `Storage e arquivos`. Obrigatório
  para persistência, migrations, queries, payloads, APIs, serialização,
  validação, arquivos, concorrência ou alteração de estado.
- **Eventos e processamento assíncrono:** as subseções de arquitetura
  `Event-Driven Architecture`, `Saga / Process Manager`, `Outbox Pattern` e
  `Inbox Pattern`, além de `Event bus, filas e workers`. Obrigatório para
  eventos, jobs, filas, workers, retries, entrega, ordenação ou idempotência.
- **Erros e observabilidade:** `Logging e observabilidade`, `Configuração e
  ambiente` e `Erros e exceptions`. Obrigatório para try/catch, falhas
  silenciosas, logs, métricas, tracing, health checks, feature flags,
  configuração e diagnóstico operacional.
- **Testes:** `Testes`. Obrigatório ao modificar comportamento ou testes e ao
  avaliar cobertura, regressão, contratos ou efeitos colaterais.
- **Performance:** `Performance e escalabilidade`. Obrigatório quando houver
  consultas, loops, coleções, processamento em lote, I/O, cache, concorrência,
  chamadas externas ou caminhos de alta frequência. Inclua na dúvida sobre
  custo ou volume.
- **Integrações externas:** `Integrações externas` e, quando houver fronteira de
  domínio, `Anti-Corruption Layer`. Obrigatório para APIs, providers, webhooks,
  timeouts, retries, fallbacks e circuit breakers.
- **Documentação e entrega:** `Documentação e manutenção` e `CI/CD, qualidade e
  entrega`. Obrigatório para endpoints, services expostos por HTTP, Swagger ou
  OpenAPI, configuração, dependências, migrations, deploy e documentação.
- **Code review:** `Severidade e prioridade`, `Evidência obrigatória no código`,
  `Formato obrigatório de resposta do review` e `Pendências técnicas`.
  Obrigatório somente quando o pedido for review, auditoria ou relato de
  pendências técnicas, junto das regras especializadas definidas em
  `AGENTS.md` e na skill aplicável.

## Critérios permanentes de aceite

- Respeite a arquitetura, os padrões, o domínio e as responsabilidades já
  existentes antes de propor uma estrutura nova.
- Prefira o menor patch correto e seguro. Não misture correção funcional com
  refatoração ampla sem necessidade comprovada.
- Aplique SOLID, DRY, KISS e YAGNI de forma pragmática; não force padrões nem
  crie abstrações prematuras.
- Não duplique regras ou métodos, mas não deduplique trechos apenas por
  semelhança superficial.
- Preserve contratos existentes ou torne qualquer quebra explícita, justificada
  e segura para migração e rollback.
- Valide entradas, estados, contratos, ownership, autorização e isolamento de
  tenant em todas as fronteiras aplicáveis.
- Nunca permita IDOR, vazamento de dados ou exposição de secrets e informações
  sensíveis.
- Avalie performance de forma concreta, incluindo N+1, consultas
  desnecessárias, falta de índices, listas ilimitadas, processamento excessivo,
  concorrência e chamadas externas.
- Trate erros de forma previsível. Não engula exceptions, não use try/catch sem
  finalidade e não permita falhas silenciosas.
- Preserve consistência transacional, idempotência e invariantes quando o fluxo
  alterar estado ou produzir efeitos colaterais.
- Garanta observabilidade suficiente para explicar decisões e falhas de fluxos
  críticos, sem registrar dados sensíveis.
- Teste comportamento e riscos relevantes, incluindo erros, contratos,
  autorização, isolamento, regressões e efeitos colaterais; não use mocks que
  tornem a prova vazia.
- Comentários incorporados ao código devem ser em inglês e existir somente
  quando preservarem uma razão ou restrição que o próprio código não consegue
  expressar.
- Ao criar ou alterar um service, rastreie seus consumidores. Se houver
  exposição HTTP em projeto com Swagger/OpenAPI, confira e atualize no
  controller a documentação afetada.
- Não conclua que há bug ou causa confirmada sem evidência no fluxo completo.
  Separe fatos comprovados de hipóteses e declare limitações de validação.
- Não considere a mudança pronta enquanto testes, contratos, documentação,
  tratamento de erros, segurança, performance e possíveis efeitos colaterais
  aplicáveis não tiverem sido verificados proporcionalmente ao risco.
