# Critérios universais de aceite técnico

Este arquivo centraliza os critérios comuns a qualquer linguagem. Critérios
exclusivos permanecem nos arquivos de cada stack para evitar repetição e
aplicação fora de contexto.

Estas regras são critérios de aceite obrigatórios para revisão e geração de
código em qualquer stack, projeto ou linguagem — não são exemplos opcionais.
Regras específicas de cada stack (TypeScript/React/NestJS, Go, PHP/Laravel)
estão em arquivos separados nesta mesma pasta.

## Propósito e modo de uso

Este documento não é um modelo obrigatório de implementação.

Ele deve ser usado como conjunto de critérios de aceite técnico, qualidade, segurança, arquitetura, manutenção e evolução para avaliar código, propor melhorias e validar decisões de desenvolvimento.

A IA não deve aplicar todos os padrões descritos automaticamente.
A IA deve identificar quais critérios são relevantes para o código, linguagem, framework, arquitetura e contexto analisado.

Padrões como DDD, Clean Architecture, Hexagonal Architecture, CQRS, Event-Driven Architecture, Outbox, Inbox, Saga, Strategy, Policy e Specification devem ser considerados como ferramentas possíveis, não como obrigações universais.

Não critique a ausência de um padrão quando ele não for necessário.
Não transforme preferência arquitetural em erro.
Não introduza complexidade apenas para satisfazer este documento.
Não force uma arquitetura idealizada sobre código simples que já atende bem ao problema.

Aplique primeiro as regras universais.
Depois aplique apenas as regras específicas da linguagem, framework e arquitetura realmente presentes no código analisado.

Não aplique critérios de uma linguagem, framework ou camada a código de outro
contexto.
Não critique ausência de DDD pesado em CRUD simples.
Não critique ausência de microservices quando modular monolith resolve melhor.
Não critique ausência de CQRS, Event Sourcing, Saga, Outbox ou Inbox quando o contexto não exige esse grau de confiabilidade ou separação.

Quando uma recomendação for opcional, marque como opcional.
Quando um problema for bloqueante, explique o impacto real.
Toda crítica deve estar conectada ao código analisado.
Não invente problemas.
Não seja genérico.
Não faça review cosmético como se fosse review técnico crítico.

A IA deve funcionar como revisor técnico sênior e como avaliador de aceite, não como gerador de uma arquitetura idealizada.


## Critérios de aplicação e aceite

### Definition of Done

Uma mudança só deve ser considerada pronta quando:

- resolve o problema proposto sem criar comportamento colateral indevido;
- mantém compatibilidade com contratos existentes, salvo quando a quebra for explícita e justificada;
- possui validação de entrada adequada;
- possui tratamento de erro previsível;
- respeita segurança, autorização e isolamento de tenant quando aplicável;
- possui testes relevantes para regra de negócio, erro e casos críticos;
- não introduz dependência, abstração ou arquitetura desnecessária;
- não degrada performance de forma relevante;
- mantém logs, métricas ou rastreabilidade quando o fluxo for crítico;
- atualiza documentação, contrato, migration ou instrução operacional quando necessário;
- permite rollback ou mitigação quando o risco operacional justificar.

### Severidade e prioridade

Classifique problemas por severidade e prioridade.

Severidade:

- Crítica: risco de segurança, perda de dados, vazamento entre tenants, indisponibilidade, corrupção de estado ou quebra grave de contrato.
- Alta: bug provável, inconsistência relevante, falha de autorização, problema transacional ou dívida técnica séria.
- Média: manutenção, testabilidade, clareza, performance moderada ou acoplamento ruim.
- Baixa: melhoria de legibilidade, organização ou padronização.

Prioridade:

- P0: corrigir antes de qualquer merge/deploy.
- P1: corrigir antes do merge salvo exceção justificada.
- P2: corrigir em seguida ou no mesmo ciclo.
- P3: melhoria opcional ou refatoração futura.

Não trate tudo como bloqueador.
Não trate gosto pessoal como severidade alta.
Não trate melhoria opcional como risco crítico.

### Evidência obrigatória no código

Toda crítica deve estar ancorada em evidência concreta do código analisado.

Evite afirmações genéricas como:

- “isso pode causar problemas de manutenção”;
- “isso viola Clean Architecture”;
- “isso não é escalável”.

Prefira:

- apontar arquivo, função, classe, trecho ou comportamento específico;
- explicar qual contrato foi violado;
- explicar qual cenário quebra;
- explicar qual risco real existe;
- sugerir a menor correção suficiente.

Se a evidência não estiver disponível, marque a conclusão como hipótese e informe o que falta para confirmar.

### Preferência por patch mínimo

Prefira a menor alteração correta.

Não reescreva grandes partes do sistema se uma correção pequena, segura e coerente resolver o problema.

Só proponha refatoração ampla quando:

- houver dívida técnica real bloqueando evolução;
- houver risco concreto de bug, segurança ou inconsistência;
- a mudança atual piorar acoplamento ou duplicação de forma relevante;
- o benefício compensar o risco da alteração.

### Controle contra overengineering

Arquitetura deve servir ao problema, não o contrário.

Não force DDD, Clean Architecture, Hexagonal, CQRS, Event Sourcing, Saga, Outbox, Inbox, Specification, Strategy ou Policy apenas porque são padrões conhecidos.

Use padrões quando eles reduzirem risco, aumentarem clareza, protegerem invariantes, melhorarem testabilidade ou isolarem dependências reais.

CRUD simples pode continuar simples.
Domínio rico deve proteger regras reais.
Código simples, correto e testável é melhor que arquitetura sofisticada sem necessidade.

### Compatibilidade e migração incremental

Avalie compatibilidade e migração incremental.

Verifique se a mudança:

- quebra APIs públicas;
- altera schema de banco de forma incompatível;
- exige backfill;
- exige feature flag;
- exige plano de rollback;
- altera payload de evento consumido por outros serviços;
- altera comportamento esperado por clientes existentes;
- permite deploy seguro em etapas;
- funciona durante período de coexistência entre versões antigas e novas;
- exige migração reversível ou estratégia expand-and-contract.

### Regra contra refatoração invisível

Não misture correção funcional com refatoração ampla sem necessidade.

Se houver refatoração, ela deve:

- ter motivo claro;
- preservar comportamento;
- ter testes protegendo comportamento anterior;
- não aumentar escopo da mudança sem justificativa;
- não esconder alteração funcional dentro de reorganização de código.

## Catálogo de padrões e critérios detalhados

As seções abaixo — arquitetura, DDD, Clean Architecture, Hexagonal,
multi-tenancy, segurança, autenticação/autorização, transações, banco,
eventos, filas, storage, observabilidade, configuração, erros, testes,
performance, integrações, documentação e CI/CD — continuam válidas para
qualquer stack quando forem relevantes. Os detalhes exclusivos de linguagem,
framework ou tecnologia ficam nos arquivos específicos desta pasta e devem ser
aplicados somente quando a stack correspondente estiver presente.

### Regras gerais

- Manter os padrões já existentes no projeto.
- Não introduzir arquitetura paralela sem necessidade.
- Não resolver parcialmente um problema criando dívida técnica.
- Não introduzir complexidade desnecessária.
- Preferir código simples, legível e previsível.
- Usar nomes claros para variáveis, funções, classes, arquivos e módulos.
- Evitar duplicação de lógica.
- Evitar funções grandes demais.
- Evitar classes ou services com responsabilidades demais.
- Não deixar código morto.
- Não deixar logs esquecidos.
- Não deixar mocks, gambiarras, TODOs críticos ou código temporário em produção.
- Não ignorar erros silenciosamente.
- Não usar try/catch apenas para engolir exception.
- Não expor dados sensíveis.
- Não hardcodar configurações.
- Não misturar regra de negócio com detalhes de infraestrutura.
- Não quebrar contratos públicos sem necessidade.
- Garantir compatibilidade com o restante do sistema.
- Garantir que a solução seja testável.
- Avaliar impacto em segurança, performance, manutenção, escalabilidade e observabilidade.
- Avaliar se a solução é simples o suficiente para o problema real.
- Avaliar se a solução cria acoplamento desnecessário.
- Avaliar se a mudança respeita o domínio do sistema.
- Avaliar se a mudança é segura para rollback.
- Avaliar se existem efeitos colaterais escondidos.
- Evitar abstrações prematuras.
- Evitar funções com muitos níveis de indentação.
- Evitar nomes vagos como Manager, Helper, Utils, CommonService ou Processor quando a responsabilidade real não está clara.
- Evitar parâmetros booleanos ambíguos; prefira métodos explícitos ou objetos de opção nomeados.
- Evitar long parameter list; agrupe parâmetros quando fizer sentido sem esconder conceitos importantes.
- Evitar primitive obsession quando value objects ou tipos específicos aumentarem segurança e clareza.
- Evitar feature envy: lógica de um domínio não deve viver em outro por conveniência.
- Evitar shotgun surgery: mudanças pequenas não deveriam exigir alteração espalhada em muitos pontos sem motivo.
- Evitar acoplamento temporal escondido, quando um método só funciona se outro foi chamado antes sem contrato explícito.
- Evitar estado mutável compartilhado sem controle.
- Evitar duplicação real de regra de negócio; não abstrair cedo demais apenas por semelhança superficial.
- Evitar componentes de interface grandes demais ou com responsabilidades excessivas.
- Código morto, TODO crítico, workaround temporário e log esquecido não devem ir para produção.

#### Comentários no código

Estas regras se aplicam a comentários inline, blocos de comentário, docblocks
e docstrings durante a geração, alteração e revisão de código.

Siga obrigatoriamente esta ordem de decisão:

1. **Remover:** se nomes, tipos, estrutura, dados e testes já comunicam a
   informação, não mantenha o comentário.
2. **Expressar no código:** se um nome melhor, método extraído, constante
   nomeada, tipo, objeto ou estrutura consegue comunicar a intenção, faça isso
   em vez de comentar.
3. **Comentar:** somente a razão ou restrição relevante que continuar impossível
   de deduzir depois dos passos anteriores.

- Não reescreva ou resuma automaticamente um comentário ruim. Primeiro decida
  se ele deve existir usando a ordem acima.
- Adicione comentário somente quando ele preservar informação relevante que o
  código não consegue expressar com clareza: razão de negócio, invariante,
  restrição externa, trade-off, efeito colateral relevante ou motivo de um
  workaround.
- Um comentário útil deve acrescentar informação causal: por que uma escolha
  surpreendente é necessária ou qual comportamento relevante seria quebrado se
  ela fosse alterada. Contexto que apenas descreve participantes, chamadas ou
  sequência de execução não é justificativa suficiente.
- Não narre o que a linha seguinte faz, não traduza a sintaxe para linguagem
  natural e não repita nomes de classes, métodos, variáveis, testes ou condições.
- Escreva para um desenvolvedor que não conhece a tarefa nem participou da
  implementação. Use linguagem objetiva, concisa, profissional e alinhada ao
  vocabulário do domínio.
- Escreva sempre em inglês todo comentário incorporado ao código, incluindo
  comentários inline, docblocks, docstrings, TODOs e FIXMEs novos ou alterados.
  Não traduza comentários preexistentes fora do escopo apenas para uniformizar o
  idioma. Comentários de review e comunicação com o usuário continuam no idioma
  da conversa.
- Cada comentário deve ter uma única finalidade e, em regra, no máximo duas
  frases curtas. Se a explicação exigir narrativa, histórico, vários cenários ou
  uma lista de consumidores, mova-a para documentação apropriada e mantenha no
  código apenas a restrição indispensável.
- Coloque o comentário imediatamente junto da decisão, restrição ou trecho que
  ele explica. Não documente em uma declaração a justificativa de outro trecho
  distante.
- Não use nomes de chamadores, métodos consumidores, tabelas ou detalhes da
  implementação como substitutos da responsabilidade ou da regra de domínio.
  Referencie outro símbolo somente quando existir uma dependência contratual
  real que não possa ser expressa pelo código.
- Não inclua ticket, PR, critério de aceite, identificador interno de decisão ou
  conversa em comentários comuns. Uma referência externa só é aceitável quando
  for indispensável para rastrear a origem de uma restrição ou workaround que
  não possa ser documentado integralmente no repositório; mesmo assim, registre
  primeiro a razão autossuficiente e siga a convenção do projeto.
- Não deixe no código raciocínio interno da IA, relato de como a solução foi
  produzida, justificativa dirigida ao revisor ou planejamento de trabalho
  futuro.
- TODO, FIXME e comentários temporários só são aceitáveis quando a convenção do
  projeto permitir e houver contexto acionável, responsável ou referência
  rastreável e condição clara para remoção. Pendências críticas não devem ser
  postergadas por comentário.
- Não duplique a mesma justificativa em implementação, teste, helper e
  documentação. Mantenha-a no ponto que protege diretamente a decisão e use
  nomes claros nos demais lugares.
- Em testes, expresse o cenário por meio do nome, preparação, dados e asserções.
  Comente somente comportamento surpreendente de fixture, infraestrutura ou
  ambiente que não possa ser comunicado claramente pelo próprio teste. Se o
  comentário for necessário para explicar um setup complexo, avalie primeiro se
  o setup pode ser simplificado ou encapsulado com um nome que revele a intenção.
- Docblocks e docstrings devem complementar o contrato com informação que tipos
  e assinaturas não expressam, como estruturas, genéricos, invariantes, efeitos
  colaterais, erros ou condições especiais. Não os adicione sistematicamente a
  toda classe ou método nem repita a assinatura em prosa.
- Docblocks de classe devem resumir, em no máximo uma frase, uma responsabilidade
  de domínio que o nome não deixe clara. Não liste o que a classe não faz, seus
  chamadores, métodos consumidores ou o histórico da implementação.
- Docblocks de métodos de consulta, getters, predicados e operações simples devem
  ser removidos quando apenas reformularem o nome e o tipo de retorno. A diferença
  entre dois conceitos deve ser expressa primeiro pelos nomes e pelos tipos.
- Toda afirmação sobre comportamento deve ser confirmada no fluxo relevante do
  código. Não documente hipótese, intenção presumida ou causa não validada como
  fato.
- Ao alterar código, confronte comentários próximos, docblocks e docstrings com a
  implementação atual. Atualize ou remova qualquer texto desatualizado,
  contraditório, deslocado ou que tenha perdido a utilidade.
- Considere cada comentário um contrato de manutenção: informação incorreta ou
  ambígua é pior que sua ausência.
- Antes de concluir uma mudança, faça uma passagem exclusiva por todos os
  comentários e docblocks novos, alterados ou afetados. Para cada um, classifique
  internamente como `REMOVER`, `EXPRESSAR NO CÓDIGO` ou `MANTER`; não apresente
  essa classificação no fonte nem na resposta, apenas execute a decisão.
- Só classifique como `MANTER` se todas as respostas abaixo forem positivas:
  - a informação não pode ser deduzida do código, dos tipos ou do nome do teste;
  - existe uma razão ou restrição concreta, e não apenas descrição do fluxo;
  - o texto continuará compreensível sem acesso à tarefa, PR ou conversa atual;
  - o comentário está no ponto exato da decisão e corresponde ao código atual;
  - remover o comentário faria um mantenedor perder informação necessária para
    alterar o trecho com segurança.
  Se qualquer resposta for negativa, remova o comentário ou expresse a intenção
  no código.

### Arquiteturas e padrões que devem ser considerados

Use estes modelos como referência para identificar problemas arquiteturais. Não aplique todos cegamente; avalie se fazem sentido para o contexto.

#### Clean Architecture

- Verificar se regras de negócio não dependem de frameworks.
- Verificar se casos de uso são independentes de banco, HTTP, filas e providers externos.
- Verificar se dependências apontam para dentro, não para fora.
- Verificar se entidades de domínio são protegidas contra dependências externas.
- Verificar se adapters convertem dados externos para modelos internos.
- Verificar se controllers apenas traduzem entrada HTTP para casos de uso.
- Verificar se presenters/mappers evitam vazar estruturas internas.

#### Arquitetura Hexagonal / Ports and Adapters

- Verificar se dependências externas são acessadas por ports/interfaces.
- Verificar se adapters implementam detalhes como ORM, filas, cache, HTTP client, storage e email.
- Verificar se o domínio não conhece implementações concretas de ORM, filas, cache, storage, mensageria ou APIs externas.
- Verificar se trocar um provider externo não exige mudar regra de negócio.
- Verificar se ports possuem contratos claros e pequenos.
- Evitar ports genéricas demais.
- Evitar adapter com regra de negócio.

#### DDD — Domain-Driven Design

- Verificar se bounded contexts estão respeitados.
- Verificar se módulos não invadem domínios vizinhos.
- Verificar se entidades, value objects, aggregates, repositories e domain services fazem sentido.
- Verificar se invariantes do domínio são protegidas.
- Verificar se regras críticas não estão espalhadas.
- Verificar se o vocabulário do código reflete o domínio real.
- Evitar “DDD teatral” em CRUD simples.
- Evitar domínio anêmico quando existem regras importantes.
- Evitar acoplamento direto entre aggregates.
- Usar IDs/referências entre aggregates quando apropriado.
- Verificar consistência transacional dentro do aggregate.
- Verificar consistência eventual entre aggregates quando necessário.

#### Modular Monolith

- Verificar se o monólito está dividido em módulos fortes e independentes.
- Verificar se módulos se comunicam por contratos claros.
- Verificar se um módulo não acessa tabelas internas de outro módulo diretamente.
- Verificar se imports entre módulos não criam dependência circular.
- Verificar se cada módulo tem responsabilidade clara.
- Verificar se é possível extrair um módulo no futuro sem reescrever o sistema inteiro.
- Evitar “monólito embolado” com services acessando tudo.

#### CQRS

- Avaliar se comandos e queries estão separados quando o domínio justifica.
- Verificar se command handlers alteram estado.
- Verificar se query handlers apenas leem dados.
- Evitar CQRS desnecessário em CRUD simples.
- Verificar se modelos de leitura não vazam regras de escrita.
- Verificar consistência eventual quando modelos de leitura são separados.
- Verificar idempotência em commands sensíveis.

#### Event-Driven Architecture

- Verificar se eventos representam fatos já ocorridos, não comandos disfarçados.
- Eventos devem ser nomeados no passado quando forem domain events.
- Payloads devem ser explícitos, pequenos e versionáveis.
- Não enviar entidades inteiras como payload se IDs bastam.
- Eventos externos devem ser versionáveis (payload e nome preparados para receber versão), mas só receber versionamento explícito (sufixo `.v1`/`.v2` no nome ou campo `version` no payload) quando o usuário confirmar a necessidade E o projeto estiver em produção com consumidor real escutando. Antes disso, YAGNI: não introduzir versão preventiva.
- Eventos só devem ser publicados após commit da transação.
- Avaliar uso de outbox pattern para confiabilidade.
- Consumidores devem ser idempotentes.
- Retries não podem duplicar efeito.
- Eventos devem carregar tenantId e correlationId quando aplicável.

#### Saga / Process Manager

- Considerar saga quando um fluxo envolve múltiplas etapas, módulos ou serviços.
- Verificar se compensações existem para falhas parciais.
- Verificar se o estado do processo é persistido quando necessário.
- Evitar transação distribuída improvisada.
- Verificar se retries e timeouts são tratados.
- Verificar se cada etapa é idempotente.

#### Outbox Pattern

- Considerar outbox quando uma mudança no banco precisa publicar evento externo com garantia.
- Verificar se evento e alteração de estado são gravados na mesma transação.
- Verificar se existe worker/processador da outbox.
- Verificar se processamento é idempotente.
- Verificar se existem retries e controle de falha permanente.

#### Inbox Pattern

- Considerar inbox para consumo confiável de eventos externos.
- Verificar se mensagens já processadas não são processadas novamente.
- Verificar deduplicação por messageId/eventId.
- Verificar persistência do status de processamento.

#### Repository Pattern

- Verificar se repositories expressam operações do domínio, não apenas CRUD genérico.
- Evitar repository genérico demais quando prejudica clareza.
- Verificar se repository não contém regra de negócio que deveria estar no domínio.
- Verificar se queries específicas de leitura podem estar em query services quando apropriado.

#### Unit of Work

- Verificar se operações relacionadas compartilham a mesma transação.
- Verificar se a transação não vaza para camadas indevidas.
- Verificar se commit/rollback são previsíveis.
- Evitar transações longas.

#### Specification Pattern

- Considerar quando regras de filtragem/validação são complexas e reutilizáveis.
- Evitar specifications desnecessárias para regras simples.
- Verificar se regras são compostas de forma clara.

#### Policy Pattern

- Usar policies para regras de permissão e autorização mais complexas.
- Verificar se autorização não está espalhada em controllers/services.
- Verificar se policy considera tenant, role, membership, ownership e estado do recurso.

#### Strategy Pattern

- Considerar strategy quando há múltiplas variações de algoritmo ou comportamento.
- Evitar if/else gigante por tipo/provider/status quando strategy deixaria mais limpo.
- Não usar strategy se só existe uma variação e não há previsão real de expansão.

#### Factory Pattern

- Verificar se criação de entidades complexas está encapsulada.
- Evitar criação espalhada com objetos parcialmente válidos.
- Factories devem proteger invariantes iniciais.

#### Anti-Corruption Layer

- Usar ACL quando integrar com sistemas externos ou legados.
- Não deixar modelos externos contaminarem o domínio interno.
- Mapear formatos externos para modelos internos.
- Isolar inconsistências de APIs externas.

#### BFF — Backend for Frontend

- Considerar BFF quando diferentes clientes precisam de contratos diferentes.
- Evitar o frontend montar dados complexos demais a partir de múltiplos endpoints.
- Evitar backend expor modelo interno cru apenas para conveniência da UI.

#### Vertical Slice Architecture

- Considerar organização por feature/caso de uso em vez de camadas genéricas quando fizer sentido.
- Verificar se arquivos relacionados à mesma feature estão próximos.
- Evitar dispersão excessiva de lógica por pastas genéricas.
- Manter boundaries claros mesmo usando vertical slices.

#### SOLID

- Single Responsibility: cada classe/função deve ter um motivo claro para mudar.
- Open/Closed: extensão sem modificar código sensível quando aplicável.
- Liskov: substituições não devem quebrar contrato esperado.
- Interface Segregation: interfaces pequenas e específicas.
- Dependency Inversion: depender de abstrações, não implementações concretas.

#### Princípios gerais

- DRY: evitar duplicação real, não abstrair cedo demais.
- KISS: manter simples.
- YAGNI: não criar solução para problema que ainda não existe.
- Separation of Concerns: separar responsabilidades.
- High Cohesion: manter código relacionado junto.
- Low Coupling: reduzir dependências desnecessárias.
- Fail Fast: falhar cedo em estados inválidos.
- Secure by Default: defaults seguros.
- Least Privilege: permissões mínimas necessárias.

### Backend — arquitetura e design

- Respeitar separação entre domain, application e infrastructure.
- Domain não deve depender de framework, ORM, HTTP, filas, banco, cache ou serviços externos.
- Application deve orquestrar casos de uso.
- Infrastructure deve implementar detalhes externos.
- Controllers devem ser finos.
- Controllers não devem conter regra de negócio.
- Services não devem virar classes gigantes com múltiplas responsabilidades.
- Regras de negócio devem ficar em domain models, policies, domain services ou use cases.
- Não colocar regra de negócio em mecanismos de framework ou infraestrutura.
- Usar interfaces/ports para dependências externas.
- Aplicar Dependency Inversion Principle.
- Não acoplar diretamente com implementações de fila, mensageria, storage, email, cache ou ORM fora dos adapters.
- Evitar dependência circular entre módulos.
- Respeitar boundaries entre módulos e domínios.
- Não acessar repository de outro contexto diretamente.
- Não compartilhar entidades internas entre bounded contexts sem contrato claro.
- Usar arquitetura hexagonal onde fizer sentido.
- Não aplicar DDD de forma teatral ou exagerada onde CRUD simples resolveria.
- Evitar overengineering.

### Multi-tenancy

- Toda entidade tenant-aware deve possuir organization_id ou tenant_id.
- Toda query tenant-aware deve filtrar por organization_id ou tenant_id.
- Nunca confiar apenas no frontend para isolamento de tenant.
- Troca de organização deve validar membership.
- Usuário não pode acessar dados de organização da qual não participa.
- Roles e permissões devem ser validadas dentro do tenant correto.
- Seeds devem respeitar isolamento entre tenants.
- Testes devem cobrir isolamento entre tenants.
- Unique constraints devem considerar tenant quando necessário.
- Exemplo: email único global ou único por organização precisa ser decisão explícita.
- Logs, auditoria e eventos devem carregar tenantId quando relevante.
- Background jobs também devem preservar tenantId.
- Webhooks e workers não podem perder contexto de tenant.
- Cache deve incluir tenantId na chave quando o dado for tenant-aware.
- Não pode existir vazamento de dados entre tenants por cache, query, fila ou storage.
- Relatórios e dashboards devem respeitar escopo do tenant.
- Admin global e admin de tenant devem ter permissões claramente separadas.
- A criação de organizações deve ser restrita a papéis autorizados.
- Convites de usuários devem validar organização e permissões.
- Remoção de usuário da organização deve invalidar acessos quando necessário.

### Segurança

- Nenhum dado sensível deve aparecer em logs.
- Tokens, senhas, refresh tokens, cookies, secrets e documentos sensíveis não devem ser logados.
- Senhas devem usar Argon2 ou bcrypt corretamente.
- Refresh token não deve ser salvo em texto puro.
- Refresh token deve ser salvo como hash no banco.
- Refresh token deve ter rotação quando aplicável.
- Revogação de refresh token deve ser possível.
- Logout deve invalidar refresh token.
- JWT deve validar assinatura, expiração, issuer, audience e claims quando aplicável.
- Não aceitar token expirado.
- Não confiar em claims sem validação.
- Rate limit deve existir em endpoints críticos.
- Login, refresh token, forgot password, upload e endpoints públicos precisam de proteção especial.
- A validação deve aceitar somente campos permitidos e rejeitar campos extras quando aplicável.
- Upload deve validar tamanho, extensão, MIME type e magic bytes.
- Não confiar apenas na extensão do arquivo.
- Exceptions não devem expor stack trace ao client.
- Mensagens de erro não devem vazar detalhes internos.
- CORS deve estar configurado corretamente.
- Cookies, quando usados, devem ter HttpOnly, Secure e SameSite adequados.
- CSRF deve ser considerado quando autenticação usa cookie.
- Endpoints administrativos devem validar role/permissão.
- Dados sensíveis devem ser criptografados quando necessário.
- Secrets devem vir de env ou secret manager.
- Não hardcodar API keys, tokens, senhas ou URLs sensíveis.
- Validar ownership antes de qualquer leitura, escrita, update ou delete.
- Não permitir IDOR, ou seja, acesso a recurso de outro usuário/tenant apenas trocando ID.
- Sanitizar entradas quando houver risco de injection.
- Evitar SQL injection usando query builders/ORM corretamente.
- Evitar NoSQL injection se aplicável.
- Headers de segurança devem ser considerados.
- Implementar auditoria em ações críticas.
- Validar webhooks por assinatura quando disponível.
- Não vazar diferença entre “usuário existe” e “usuário não existe” em fluxos sensíveis quando isso permitir enumeração.
- Proteger forgot password contra abuso.
- Tokens de reset de senha devem ser de uso único, expirar rápido e ser armazenados como hash.
- Ações críticas podem exigir reautenticação.
- Verificar se a mudança coleta dados pessoais sem necessidade.
- Evitar expor dados pessoais em logs, eventos, filas ou analytics.
- Respeitar minimização de dados e evitar retenção indevida.
- Permitir rastreabilidade de ações críticas.
- Considerar mascaramento, pseudonimização ou anonimização quando apropriado.
- Proteger dados sensíveis em exportações, relatórios e integrações.
- Respeitar o princípio de menor privilégio no acesso aos dados.
- Evitar enviar dados pessoais desnecessários para serviços externos.

### Autenticação e autorização

- Login deve separar autenticação de autorização.
- Login federado e login local devem convergir para um modelo interno consistente de usuário.
- Usuário federado não deve burlar validações internas.
- Verificar se usuário está ativo antes de autenticar.
- Verificar se organização está ativa antes de permitir acesso.
- Permissões devem ser checadas no backend.
- Não confiar em role enviada pelo client.
- Claims do token devem ser mínimas e seguras.
- Mudanças críticas de permissão devem invalidar sessão/token quando necessário.
- Permissões devem considerar usuário, organização, papel, escopo e ownership.
- Separar RBAC, ABAC e policies quando necessário.
- Não espalhar checagens de permissão em ifs duplicados.
- Evitar permissões mágicas hardcoded sem enum/contrato claro.

### Transações e consistência

- Operações críticas devem usar transação.
- Criar entidade + audit log + eventos relacionados deve ser consistente.
- Eventos só devem ser emitidos após persistência bem-sucedida.
- Considerar outbox pattern quando evento externo depende de transação.
- Handlers de fila devem ser idempotentes.
- Retry de job não pode duplicar efeito.
- Operações financeiras, auditoria e criação de recursos críticos precisam de proteção contra duplicidade.
- Verificar race conditions.
- Usar locks ou constraints quando necessário.
- Não depender apenas de validação em memória para garantir unicidade.
- Banco deve proteger invariantes importantes.
- Verificar se existe risco de lost update.
- Verificar se optimistic locking ou versionamento é necessário.
- Verificar se consistência eventual está documentada quando existir.
- Proteger contra double submit e processamento simultâneo do mesmo recurso.
- Verificar a atomicidade entre mudança de estado, evento, auditoria e side effects.
- Verificar a consistência entre estado persistido e side effects externos.

### Domínio e regras de negócio

- Entidades de domínio não devem depender de frameworks.
- Exceptions de domínio devem ser próprias, sem depender de exceptions do framework ou da camada de transporte.
- Estados inválidos devem ser impossíveis ou tratados explicitamente.
- Invariantes devem ser protegidas.
- Regras críticas não devem estar espalhadas em múltiplos services.
- Policies devem concentrar decisões de autorização/regra quando fizer sentido.
- Value Objects devem ser usados quando agregam segurança e clareza.
- Evitar anemia excessiva do domínio quando existe regra importante.
- Evitar domínio artificialmente complexo em CRUD simples.
- Regras como “template published não pode editar” devem estar protegidas no domínio ou use case correto.
- Não confiar que a UI impedirá ações inválidas.
- Agregados devem proteger consistência interna.
- Eventos de domínio devem representar fatos importantes do negócio.
- Domain services devem ser usados quando a regra não pertence naturalmente a uma entidade.
- Evitar services genéricos chamados Manager, Helper ou Utils sem responsabilidade clara.

### DTOs, contratos e validação

- DTOs não devem vazar entidades do banco.
- DTOs de entrada e saída devem ser separados quando necessário.
- Não retornar senha, hash, refresh token ou campos sensíveis.
- Transformações devem ser explícitas.
- Campos opcionais devem ser tratados corretamente.
- Partial updates devem diferenciar undefined, null e valor vazio.
- APIs devem ter contratos estáveis.
- Mudanças breaking devem ser versionadas ou comunicadas.
- Erros devem ter formato consistente.
- Validar arrays, objetos aninhados e enums corretamente.
- Evitar aceitar payload maior do que o necessário.
- Não aceitar campos extras se eles não são usados.
- Response DTO deve ser adequado ao cliente e não ao schema interno.
- Não aceitar payload bruto do cliente e aplicá-lo diretamente em entidade ou modelo sem controle explícito.
- Impedir alteração indevida de campos como role, tenantId, ownerId, status, isAdmin, price, permissions ou flags sensíveis.
- Garantir que update parcial não sobrescreva campos indevidos.
- Separar o input permitido do modelo interno e manter whitelist de campos mutáveis por operação.
- Proteger contra payload excessivo e campos extras.
- APIs devem ter contrato explícito e estável.
- Não retornar entidade de banco diretamente quando isso vaza campos internos ou acopla o cliente ao schema.
- Separar DTOs de entrada, saída e modelos internos quando necessário.
- Validar payloads de entrada com whitelist de campos permitidos.
- Padronizar erros, códigos e mensagens.
- Considerar Problem Details ou formato equivalente para erros de API.
- Paginação deve ser obrigatória em listagens potencialmente grandes.
- Preferir cursor-based pagination quando offset pagination causar inconsistência ou perda de performance.
- Ordenação deve ser determinística.
- Endpoints de mutação críticos devem considerar idempotency key.
- PATCH deve diferenciar undefined, null e valor vazio.
- PUT deve respeitar semântica de substituição quando adotado.
- Versionamento de API deve ser usado quando houver breaking change real.
- Manter compatibilidade retroativa quando possível.
- Validar ETag, If-Match ou versionamento otimista quando houver risco de lost update.
- Não expor detalhes internos em responses apenas por conveniência do frontend.

### Banco de dados

- Índices devem existir para campos críticos.
- organization_id/tenant_id deve ser indexado quando usado em filtros.
- Foreign keys devem ser indexadas quando necessário.
- Unique constraints devem refletir regra de negócio real.
- Migrations devem ser versionadas.
- Não alterar schema manualmente fora de migration.
- Queries devem ser eficientes.
- Evitar N+1.
- Paginação deve existir em listagens.
- Evitar retornar listas ilimitadas.
- Soft delete, se usado, deve ser consistente.
- Queries devem considerar registros deletados quando necessário.
- Campos de auditoria devem ser consistentes: createdAt, updatedAt, deletedAt, createdBy etc.
- Não carregar relações pesadas sem necessidade.
- Evitar select * quando o retorno pode ser reduzido.
- Cuidado com transações longas.
- Avaliar constraints no banco, não só validação na aplicação.
- Verificar cascade delete perigoso.
- Verificar orphan records.
- Verificar migrações reversíveis quando aplicável.
- Verificar impacto de migrações em produção.

### Event bus, filas e workers

- Services não devem depender diretamente de Bull, RabbitMQ, SQS ou provider específico.
- Usar ports/adapters para filas.
- Eventos devem ter nomes claros.
- Eventos devem ser versionáveis quando possível.
- Payloads devem ser explícitos e estáveis.
- Não enviar entidade inteira como payload se apenas IDs bastam.
- Workers não devem conter regra de negócio central.
- Workers devem chamar use cases ou application services.
- Jobs devem ser idempotentes.
- Falhas devem ser tratadas e logadas.
- Retries devem ter backoff adequado.
- Dead-letter queue deve ser considerada para falhas permanentes.
- Jobs devem carregar tenantId, correlationId e contexto mínimo necessário.
- Não vazar dados sensíveis em payload de fila.
- Verificar timeout de jobs.
- Verificar concorrência de workers.
- Verificar deduplicação.
- Verificar se job pode ser executado fora de ordem.
- Verificar se ordem importa e como ela é garantida.

### Storage e arquivos

- URLs assinadas devem ter TTL.
- Acesso a arquivos deve validar tenant e permissões.
- Não expor path local diretamente.
- Não confiar no nome original do arquivo.
- Validar tamanho máximo.
- Validar MIME e magic bytes.
- Normalizar nomes ou usar IDs internos.
- Evitar sobrescrever arquivos por colisão de nome.
- Remoção de arquivos deve ser consistente com banco.
- Arquivos órfãos devem ser tratados quando necessário.
- Storage deve ser acessado por adapter/port.
- Verificar antivírus ou scanning quando o domínio exige.
- Verificar se arquivos privados não ficam públicos por erro de configuração.

### Logging e observabilidade

- Logs devem ser estruturados.
- traceId ou correlationId deve existir por requisição.
- Logs de API e workers devem permitir correlação.
- Níveis de log devem estar corretos.
- Não deixar prints ou logs ad hoc em produção.
- Erros devem ser logados com contexto suficiente.
- Logs não devem conter dados sensíveis.
- Métricas devem existir para fluxos críticos.
- Health checks devem cobrir dependências relevantes.
- Alertas devem ser considerados para falhas críticas.
- Verificar tracing distribuído quando há múltiplos serviços.
- Verificar dashboards para endpoints críticos.
- Verificar monitoramento de filas, jobs e DLQ.

### Configuração e ambiente

- Nenhuma configuração sensível deve ser hardcoded.
- Usar mecanismo centralizado de configuração.
- Variáveis de ambiente devem ser validadas no startup.
- Defaults devem ser seguros.
- Ambientes dev, staging e production devem ser separados.
- Feature flags devem ser usadas quando fizer sentido.
- Não depender de config implícita.
- URLs, secrets, TTLs, limits e providers devem ser configuráveis.
- Verificar se config de produção não permite comportamento inseguro.
- Verificar rotação de secrets quando aplicável.

### Erros e exceptions

- Usar padrão consistente de erro.
- Considerar Problem Details ou formato equivalente.
- Códigos de erro devem ser padronizados.
- Mensagens para client devem ser seguras.
- Mensagens internas podem ser logadas, sem vazar ao usuário.
- Mapear domain exceptions para HTTP corretamente.
- Não lançar exceptions da camada de transporte dentro do domínio.
- Não retornar erro 500 para falhas esperadas de regra de negócio.
- Não engolir erro em catch.
- Não transformar todo erro em uma resposta genérica de requisição inválida.
- Preservar causa do erro nos logs.
- Diferenciar erro de validação, autorização, conflito, não encontrado e erro interno.
- Evitar mensagens ambíguas que dificultam debug.

### Testes

- Regras críticas devem ter testes.
- Auth deve ter testes.
- Multi-tenancy deve ter testes de isolamento.
- Permissões e roles devem ter testes.
- Testar casos de erro, não só happy path.
- Testes unitários devem ser isolados.
- Testes de integração devem cobrir banco, filas, webhooks e autenticação quando relevante.
- Mocks devem ser usados com critério.
- Não mockar a ponto de o teste não provar nada.
- Testes devem ser legíveis.
- Testes devem validar comportamento, não implementação interna.
- Factories/builders devem ser usados para reduzir repetição.
- Deve haver testes para race conditions ou duplicidade quando aplicável.
- Deve haver teste garantindo que queries respeitam tenantId.
- Deve haver testes para refresh token, expiração, revogação e rotação quando aplicável.
- Testes frontend devem cobrir comportamento do usuário.
- Testes não devem depender de ordem de execução.
- Testes devem ser determinísticos.
- Evitar sleeps/timeouts frágeis em testes.
- Cobertura deve priorizar risco, não porcentagem vazia.

### Performance e escalabilidade

- Evitar loops com chamadas assíncronas sequenciais quando poderiam ser paralelas com controle.
- Limitar o paralelismo ao processar grandes volumes.
- Usar paginação.
- Usar cache apenas quando houver invalidação clara.
- Cache tenant-aware deve incluir tenantId na chave.
- Evitar carregar dados demais.
- Evitar processamento pesado dentro da request quando poderia ir para fila.
- Definir timeout para chamadas externas.
- Usar retry com backoff para integrações externas.
- Não bloquear a thread ou o event loop responsável por atender requisições com processamento pesado.
- Evitar serialização excessiva.
- Verificar o impacto de dependências com escopo por requisição.
- Verificar complexidade dos algoritmos.
- Verificar uso de índices.
- Verificar payloads grandes demais.
- Verificar compressão quando aplicável.
- Verificar rate limiting para endpoints caros.

### Integrações externas

- Chamadas externas devem ter timeout.
- Falhas externas devem ser tratadas.
- Retries devem ter limite.
- Não repetir operação não idempotente sem proteção.
- Usar circuit breaker quando fizer sentido.
- Normalizar respostas externas em adapters.
- Não deixar formato externo vazar para o domínio.
- Logs de integração devem ter correlationId.
- Secrets de integração devem vir de env/secret manager.
- Webhooks devem validar assinatura quando disponível.
- Webhooks devem ser idempotentes.
- Webhooks devem responder rápido e processar pesado em fila quando necessário.
- Considerar rate limit de APIs externas.
- Considerar fallback quando integração falha.
- Considerar anti-corruption layer para sistemas externos instáveis ou legados.

### Documentação e manutenção

- Código deve ser entendível sem depender de explicação verbal.
- Decisões arquiteturais relevantes devem estar documentadas.
- README ou docs devem ser atualizados quando a mudança altera uso, setup ou contrato.
- APIs novas devem ter documentação.
- Se o projeto já tem geração de documentação de API (Swagger/OpenAPI via
  annotations, docblocks, decorators ou atributos, dependendo da linguagem),
  qualquer criação ou alteração de rota/endpoint deve atualizar essas anotações
  no mesmo PR.
- Sempre que um service for criado ou alterado, rastrear seus consumidores. Se
  ele for exposto por um controller HTTP em um projeto com Swagger/OpenAPI,
  conferir o endpoint correspondente e adicionar ou atualizar no controller a
  documentação de request, response, status, erros e comportamento afetados,
  mesmo que o controller não tenha sido inicialmente tocado pela mudança.
- A exigência de Swagger/OpenAPI não se aplica a service sem exposição HTTP nem
  a projeto que não possua esse tooling configurado. Não criar controller ou
  documentação de API artificial apenas para satisfazer a regra.
- Variáveis de ambiente novas devem ser documentadas.
- Migrations com impacto devem ser explicadas.
- Breaking changes devem ser destacadas.
- Nomes devem refletir o domínio corretamente.
- Considerar ADRs para decisões arquiteturais importantes.
- Documentar trade-offs relevantes.
- Documentar fluxos críticos como autenticação, autorização, tenant switch, jobs e eventos.

### CI/CD, qualidade e entrega

- Verificar se lint, typecheck e testes passam.
- Verificar se build passa.
- Verificar se migration roda corretamente.
- Verificar se rollback é possível quando aplicável.
- Verificar se secrets não aparecem no pipeline.
- Verificar se ambiente de CI usa configurações seguras.
- Verificar se análise estática está ativa quando aplicável.
- Verificar se dependências possuem vulnerabilidades conhecidas.
- Verificar se lockfile foi atualizado corretamente.
- Verificar se mudança exige feature flag.
- Verificar se mudança tem plano seguro de deploy.
- Avaliar a necessidade real, a maturidade, a manutenção e a licença de dependências novas ou alteradas.
- Avaliar superfície de ataque, dependências transitivas e risco de lock-in.
- Avaliar impacto no bundle, runtime ou imagem Docker.
- Evitar dependência que duplique funcionalidade existente ou resolva algo simples demais.
- Considerar rollout por tenant ou usuário, shadow mode, fallback e kill switch em mudanças arriscadas.
- Considerar migração progressiva e monitoramento específico após o deploy.
- Garantir que o rollback seja compatível com banco, eventos e cache.

## Formato obrigatório de resposta do review

Use uma única seção chamada **Pendências técnicas** e ordene os itens por
prioridade (`P0`, `P1`, `P2`, `P3`). Classifique cada item como **BUG
CONFIRMADO** quando houver comportamento incorreto ou violação de contrato
comprovados no fluxo relevante, ou como **PROBLEMA TÉCNICO** quando houver um
problema concreto de arquitetura, manutenção, testes, documentação, performance
ou qualidade sem comportamento funcional incorreto comprovado. Hipóteses não
devem ser classificadas como bug nem apresentadas como pendência confirmada.

Apresente cada pendência em um bloco sem marcador ou numeração. Na primeira
linha, use `**Problema encontrado — NATUREZA (PRIORIDADE):**`, seguido do link
para `Arquivo.ext:linha`, e termine a linha com `\` para forçar a quebra. Na
linha seguinte, reúna em um único parágrafo o comportamento observado, o impacto
concreto e a correção necessária, nessa ordem. Não use o subtítulo **Impacto e
correção**. Separe blocos consecutivos com uma linha em branco.

Escreva como uma orientação técnica entre desenvolvedores: natural, respeitosa,
objetiva e focada no código, sem julgar ou atribuir intenção ao autor. Explique o
contexto mínimo necessário sem soar burocrático ou seco. Para bug confirmado,
deixe clara a mudança necessária, preferindo `Para corrigir`. Para problema
técnico, calibre a orientação conforme a prioridade, sem tornar opcional uma
correção necessária. Evite sarcasmo, acusações, perguntas retóricas, elogios
artificiais, dramatização e expressões vagas ou condescendentes.

Não inclua veredito, pontos aprovados, categorias vazias, elogios ou resumo
final. Se não houver pendências, responda apenas
`Nenhuma pendência técnica encontrada.` Quando uma parte relevante não puder
ser validada, declare a limitação sem apresentá-la como pendência confirmada.

Modelo:

```text
## Pendências técnicas

**Problema encontrado — BUG CONFIRMADO (P1):** [Arquivo.ext:123](/caminho/absoluto/Arquivo.ext:123)\
Nesse ponto, <comportamento comprovado>. Com isso, <impacto concreto>. Para corrigir, <ação necessária>.

**Problema encontrado — PROBLEMA TÉCNICO (P2):** [OutroArquivo.ext:45](/caminho/absoluto/OutroArquivo.ext:45)\
Aqui, <problema concreto sem bug comprovado>. Isso <impacto atual ou futuro>. Nesse caso, <ajuste recomendado ou necessário>.
```
