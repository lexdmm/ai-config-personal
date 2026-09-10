---
paths:
  - "**/*.php"
  - "**/composer.json"
  - "**/phpunit.xml"
  - "**/phpunit.xml.dist"
  - "**/artisan"
---

# Regras específicas — PHP / Laravel

Aplique junto com `universal.md`.

## PHP — regras gerais

- Usar tipagem estrita quando aplicável: `declare(strict_types=1);`.
- Tipar parâmetros, retornos e propriedades sempre que possível.
- Evitar arrays associativos soltos quando DTOs, value objects ou classes simples deixarem o contrato mais claro.
- Evitar funções globais utilitárias sem contexto.
- Evitar suprimir erro com `@`.
- Evitar `mixed` sem justificativa clara.

### Enums

- Manter subconjuntos e agrupamentos semânticos de casos dentro da própria enum,
  usando método ou constante com nome de domínio. Consumidores devem consultar
  essa definição em vez de repetir arrays posicionais de casos, evitando fontes
  de verdade divergentes.
- Não tratar como agrupamento de domínio arrays associativos de payload,
  bindings que misturam outras expressões ou referências isoladas a um único
  caso; nesses cenários, manter a estrutura no contexto que a consome.

### PHPDoc

- Tipos nativos são a fonte principal do contrato. Use PHPDoc somente para
  complementá-los com informação que a assinatura não consegue expressar e que
  seja relevante para compreensão, uso correto ou análise estática.
- Use `@param`, `@return`, `@var` e templates para contratos mais precisos, como
  array shapes, tipos genéricos, `class-string`, callables e coleções tipadas.
  Eles devem representar exatamente nulabilidade, chaves opcionais e tipos
  realmente aceitos ou retornados.
- Não repita em PHPDoc tipos já expressos integralmente na assinatura nem
  descreva em prosa o nome ou o corpo do método. Getters, setters, relações
  Eloquent e operações convencionais autoexplicativas não exigem PHPDoc apenas
  por serem públicas.
- Use `@throws` apenas para exceções relevantes que podem escapar do método e
  que o chamador precise conhecer. Não liste toda exceção interna possível.
- Ao marcar uma API com `@deprecated`, informe a alternativa de migração e,
  quando conhecida, a condição ou versão de remoção.
- Não use anotações para mascarar contratos vagos ou manter arrays complexos
  indefinidamente. Quando o shape representar um conceito de domínio relevante,
  repetido ou com comportamento próprio, prefira DTO, value object ou classe
  dedicada.
- Mantenha PHPDoc sincronizado com o código e com as ferramentas adotadas pelo
  projeto, como PHPStan ou Larastan. Uma anotação mais ampla, restrita ou
  desatualizada que a implementação deve ser corrigida ou removida.

## Laravel

### Controllers, Requests e Resources

- Usar Form Requests para validação de entrada quando apropriado; payload complexo não deve ser validado diretamente no controller.
- Usar API Resources/Transformers para respostas e nunca retornar Model Eloquent diretamente quando isso expuser campos internos ou relações indevidas.
- Separar request de entrada, comando/use case e response resource.

### Eloquent e banco de dados

- Evitar N+1; usar eager loading explícito quando necessário.
- Não usar eager loading amplo sem necessidade.
- Cuidado com accessors/appends que disparam queries escondidas.
- Habilitar `Model::preventLazyLoading()` em desenvolvimento e testes quando compatível com o projeto, para detectar lazy loading não intencional.
- Usar scopes com responsabilidade clara; scopes tenant-aware devem aplicar o isolamento de forma confiável.
- Transações devem usar `DB::transaction` quando múltiplas alterações precisam ser atômicas.

#### Réplica de leitura e `useWritePdo()` — checklist de review

Antes de aceitar (ou introduzir) uma leitura forçada na primária — `useWritePdo()`, um método
tipo `getXFromPrimary()`, ou um comentário do tipo *"a réplica pode estar atrasada"* — verificar
nesta ordem. Se qualquer item bater, a forçagem é **redundante** e deve ser removida:

1. **O call-site está dentro de uma transação?** Se sim, encerra a discussão: o Laravel já lê da
   conexão de escrita. A implementação de
   `Illuminate\Database\Connection::getReadPdo()` garante:
   `if ($this->transactions > 0) { return $this->getPdo(); }`.
2. **A conexão em uso tem split `read`/`write` configurado?** Sem split, `useWritePdo()` é no-op —
   leitura e escrita vão para o mesmo lugar.
3. **A conexão tem `'sticky' => true`?** Se sim, após qualquer escrita no mesmo request as
   leituras seguintes já vão para a primária automaticamente.
4. **Qual conexão o fluxo realmente usa?** Conexão com réplica costuma ser aplicada seletivamente
   (ex.: middleware que só troca em requests GET). Fluxos de mutação (POST/PUT/PATCH/DELETE)
   frequentemente nunca tocam a réplica.

Pontos de atenção:

- Não validar essa hipótese "por ambiente" (dev não tem réplica, produção tem). O argumento por
  config é frágil e muda entre ambientes; o argumento por transação (item 1) vale em todos.
- Uma leitura forçada redundante não é neutra: mascara a intenção, sugere um problema de
  consistência que não existe e, quando adicionada a código legado, entra como mudança de
  comportamento sem flag.

### Mass assignment

- Configurar `$fillable` ou `$guarded` conscientemente.
- Nunca passar payload bruto do request diretamente para `create`, `update` ou `fill` sem filtrar campos permitidos.
- Proteger campos sensíveis como `role`, `tenant_id`, `organization_id`, `is_admin`, `status`, `owner_id`, `permissions`, `price` e flags internas.
- Diferenciar dados que o usuário pode enviar dos dados calculados pelo sistema.
- Habilitar `Model::preventSilentlyDiscardingAttributes()` em desenvolvimento e testes quando compatível com o projeto, para detectar atributos descartados silenciosamente.

### Autorização

- Usar Policies e Gates para autorização quando apropriado.
- Policies devem considerar usuário, tenant, role, ownership e estado do recurso.
- Middleware de autenticação não substitui validação de permissão.

### Services, Actions e Use Cases

- Criar services/actions/use cases quando controller ou model começarem a acumular regra de negócio.
- Models podem conter comportamento de domínio simples, mas nunca devem virar fat models que orquestram integrações, filas, storage ou casos de uso complexos.

### Jobs, Queues, Events e Listeners

- Configurar `$tries`, `backoff`, `timeout` ou `retryUntil()` de forma coerente com o efeito e o tempo de execução do job.
- Jobs, listeners, mailables, notifications e broadcasts disparados dentro de transação devem usar `after_commit`, `afterCommit()` ou contrato equivalente quando dependerem dos dados confirmados.
- Listeners não devem esconder regra de negócio crítica difícil de rastrear.

### Segurança Laravel

- Manter o middleware de proteção CSRF nos fluxos web aplicáveis; qualquer exclusão deve ser mínima e justificada.
- Para APIs, usar Sanctum, Passport, JWT ou outro mecanismo de forma coerente com o contexto.
- Quando `config:cache` fizer parte do deploy, usar `env()` somente nos arquivos de configuração, pois o `.env` não é carregado após o cache.
- Validar `config:cache`, `route:cache` e demais otimizações no processo de deploy antes de aplicá-las em produção.

### Testes Laravel

- Testar Form Requests, Policies, use cases, jobs e fluxos críticos.
- Usar factories e seeders com critério.

### Ferramentas da stack

- O formatador adotado pelo projeto, como Laravel Pint, deve passar no escopo alterado.
- PHPUnit ou Pest, PHPStan ou Larastan e os demais verificadores configurados no projeto devem passar no escopo aplicável.
