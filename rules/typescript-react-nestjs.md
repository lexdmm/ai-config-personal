# Regras específicas — TypeScript, React, NestJS

Aplique junto com `universal.md`. Este arquivo concentra os critérios
exclusivos de TypeScript, React e NestJS.

## TypeScript — regras gerais

- Não usar `any` sem justificativa muito forte.
- Tipos devem ser explícitos, corretos, seguros e expressar o domínio real.
- Preferir `unknown` a `any` quando o tipo é desconhecido, mas tratar/refinar antes de usar.
- Evitar casts desnecessários e nunca usar `as any`, `as unknown as`, non-null assertion `!` ou type assertions perigosas para silenciar erros.
- Evitar tipos amplos demais quando um union, enum, branded type ou value object simples seria mais seguro.
- Diferenciar DTOs, models, entities e response types.
- Não vazar tipo de ORM para camadas de domínio/aplicação quando arquitetura exige separação.
- Evitar `Partial<T>` em update crítico quando isso permite campos indevidos ou ambiguidade entre `undefined`, `null` e valor vazio.
- Usar `Readonly`, `readonly`, discriminated unions e tipos literais quando ajudarem a proteger contrato.
- Tratar promises corretamente; não esquecer `await` quando necessário.
- Evitar `Promise.all` sem limite para grandes volumes.
- Não engolir erro em `.catch` vazio.
- Não bloquear o event loop com processamento pesado.

## Frontend — React / TypeScript

- Verificar se os componentes são pequenos e possuem responsabilidade única.
- Separar UI de regra de negócio.
- Evitar componente “Deus” com lógica, estado, fetch, validação e renderização tudo junto.
- Preferir composição a herança.
- Criar componentes reutilizáveis quando houver real necessidade.
- Não criar abstrações genéricas cedo demais.
- Props devem ser simples, explícitas e bem tipadas.
- Evitar passar objetos gigantes por props sem necessidade.
- Evitar prop drilling excessivo.
- Avaliar se context, composition ou state manager seriam melhores.
- Estado deve estar no lugar correto.
- Estado local deve ser local.
- Estado global só deve existir quando realmente compartilhado.
- Evitar duplicar estado derivável.
- Evitar stale closure.
- Evitar unstable reference em dependency array de useEffect.
- Dependency array do useEffect deve estar correto.
- Não pode existir render loop ou ciclo infinito de renderização.
- Não usar useEffect desnecessariamente nem para lógica que possa ser derivada diretamente no render.
- Evitar setState em cascata sem necessidade.
- Evitar re-render desnecessário.
- Usar memo, useMemo e useCallback somente quando houver ganho real, nunca por precaução.
- Listas devem ter key estável e correta.
- Não usar index como key quando a lista pode mudar.
- Evitar lógica pesada dentro do render.
- Evitar chamadas de API diretamente em componentes burros.
- Componentes visuais devem receber dados prontos para renderizar.
- Adaptar dados do backend antes de chegar na UI.
- Não acoplar componente ao formato bruto da API.
- Formulários devem ter validação clara e previsível.
- Inputs controlados e não controlados devem ser usados com critério.
- Estados de loading, erro, vazio e sucesso devem ser tratados.
- UX não deve travar em caso de erro.
- Evitar race condition em fetch.
- Cancelar ou ignorar respostas antigas quando necessário.
- Garantir acessibilidade básica.
- Botões devem ter labels claros.
- Elementos interativos devem ser navegáveis por teclado quando aplicável.
- Evitar div clicável quando button ou link seriam semanticamente corretos.
- Componentes devem ser testáveis.
- Testar comportamento, não detalhes internos.
- Estilos devem ser previsíveis e isolados.
- Evitar CSS espalhado e dependências visuais escondidas.
- Seguir design system ou biblioteca interna quando existir.
- Evitar divergência visual entre botões, inputs, modais, cards e tabelas.
- Layout e conteúdo devem ter responsabilidades separadas.
- Evitar componente que controla grid, regra de negócio e conteúdo ao mesmo tempo.
- A árvore JSX e suas renderizações condicionais devem permanecer legíveis; JSX confuso exige rever a composição.

### Performance, estado e dados

- Verificar se chamadas de API estão cacheadas quando apropriado.
- Verificar invalidação correta de cache.
- Verificar se React Query, SWR, Zustand, Redux ou Context estão sendo usados corretamente, caso existam.
- Evitar estado global para dados que pertencem ao cache de servidor.
- Evitar cache duplicado em múltiplos lugares.
- Evitar race conditions em mutações.
- Garantir optimistic updates apenas quando rollback está tratado.
- Evitar renderizar listas grandes sem paginação, virtualização ou lazy loading.
- Evitar bundle desnecessariamente grande.
- Considerar code splitting quando fizer sentido.
- Evitar imports pesados em componentes carregados cedo.
- Evitar passar funções/objetos inline para componentes profundamente memoizados quando isso quebra memoização.
- Verificar tratamento de erros em boundaries quando aplicável.
- Evitar componentes que fazem fetch em cascata criando waterfalls.
- Não usar Context como depósito genérico de estado global.

## Backend — NestJS / TypeScript / multi-tenant

### Arquitetura e design

- Respeitar separação entre domain, application e infrastructure.
- Domain não deve depender de NestJS, TypeORM, Prisma, HTTP, filas, banco, cache ou serviços externos.
- Application deve orquestrar casos de uso.
- Infrastructure deve implementar detalhes externos.
- Controllers devem ser finos.
- Controllers não devem conter regra de negócio.
- Services não devem virar classes gigantes com múltiplas responsabilidades.
- Regras de negócio devem ficar em domain models, policies, domain services ou use cases.
- Não colocar regra de negócio em decorators, guards, interceptors ou pipes.
- Usar interfaces/ports para dependências externas.
- Aplicar Dependency Inversion Principle.
- Não acoplar diretamente com providers como Bull, RabbitMQ, S3, SMTP, Redis ou ORM fora dos adapters.
- Respeitar boundaries entre módulos e domínios.
- Não acessar repository de outro contexto diretamente.
- Não compartilhar entidades internas entre bounded contexts sem contrato claro.
- Usar arquitetura hexagonal onde fizer sentido.
- Não aplicar DDD de forma teatral ou exagerada onde CRUD simples resolveria.
- Evitar overengineering.

### NestJS específico

- Modules devem ser bem definidos.
- Evitar dependência circular entre modules.
- Providers devem ter escopo correto.
- Evitar request scope sem necessidade e, quando necessário, avaliar explicitamente seu impacto de performance.
- Guards devem ser usados para autenticação/autorização.
- Interceptors não devem conter regra de negócio.
- Pipes devem ser usados para validação/transformação.
- Decorators não devem esconder regra crítica.
- Middleware deve ser usado com critério.
- Injeção de dependência deve ser clara.
- Evitar service locator pattern.
- Testar guards, interceptors e pipes críticos.
- Verificar se imports/exports dos modules estão corretos.
- Evitar módulos globais sem necessidade.
- Verificar lifecycle hooks quando usados.
- Verificar se providers singleton não guardam estado por request indevidamente.

### Validação, erros e configuração no NestJS

- TenantGuard deve ser aplicado corretamente em rotas protegidas.
- AuthGuard, TenantGuard e RolesGuard devem estar na ordem correta.
- DTOs devem validar input com ValidationPipe.
- Deve existir whitelist e forbidNonWhitelisted quando aplicável.
- Exceptions de domínio devem ser próprias; nunca lançar HttpException diretamente no domain.
- class-validator deve ser usado corretamente.
- class-transformer deve ser usado apenas quando necessário.
- Não usar console.log solto em produção.
- Usar ConfigService ou mecanismo centralizado.
- Não transformar todo erro em BadRequestException genericamente.
