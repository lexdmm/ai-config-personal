---
paths:
  - "**/*.go"
  - "**/go.mod"
  - "**/go.sum"
---

# Regras específicas — Go

Aplique junto com `universal.md`.

## Simplicidade idiomática

- Preferir código simples, explícito e idiomático.
- Interfaces devem ser pequenas, normalmente definidas pelo consumidor e não devem ser criadas apenas para “facilitar teste” sem benefício real.
- Packages devem ser coesos e ter responsabilidade clara.
- Evitar pacote `utils` ou `common` gigante.
- Nomes devem ser claros, curtos quando idiomáticos e específicos quando o domínio exigir.

## Context, timeout e cancelamento

- Receber `context.Context` como primeiro parâmetro e propagá-lo em chamadas externas, banco, filas e operações canceláveis.
- Não armazenar context em struct sem motivo muito forte.
- Não passar `nil` como context.
- Definir timeouts para HTTP clients, queries e integrações externas.
- Sempre executar a função de cancelamento retornada ao criar context com timeout, deadline ou cancelamento.
- Evitar goroutines que ignoram cancelamento.

## Erros

- Retornar erros explicitamente.
- Não usar `panic` fora de inicialização, testes ou situações realmente irrecuperáveis.
- Usar wrapping com `%w` quando a causa fizer parte do contrato e precisar ser inspecionada, sem expor detalhes internos que deveriam permanecer encapsulados.
- Usar `errors.Is` e `errors.As` para inspecionar cadeias de erros; não comparar mensagens de erro.
- Não engolir erro com `_` sem justificativa clara.
- Evitar logar e retornar o mesmo erro em múltiplas camadas causando duplicidade ruidosa.

## Concorrência

- Goroutines devem ter ciclo de vida claro.
- Evitar goroutine leak.
- Channels devem ser usados com critério; não usar channel onde mutex ou chamada direta seria mais simples.
- Proteger estado compartilhado com mutex, channel ou outra estratégia clara.
- Usar `errgroup` quando houver múltiplas goroutines coordenadas com erro/cancelamento.
- Limitar concorrência em processamento de lotes.
- Não usar `go func()` em request sem controle, cancelamento ou observabilidade.

## HTTP, APIs e middlewares

- Middlewares devem tratar cross-cutting concerns: auth, logging, tracing, recovery, rate limit.
- Handler HTTP não deve conter regra de negócio complexa.
- Separar parsing/validação de request, execução do caso de uso e response.
- Não expor struct interna diretamente quando isso acopla contrato ao domínio.
- Validar payloads e tamanhos máximos.
- Configurar timeouts no servidor HTTP.
- Usar recovery middleware sem esconder falhas importantes.

## Banco de dados e transações

- Não vazar detalhes de SQL/driver para domínio quando arquitetura exigir separação.
- Queries devem usar context e timeout.

## Validação e modelos

- Mapear zero values, nullability e campos opcionais com cuidado; zero nem sempre significa ausência.
- Usar ponteiros, tipos nullable ou wrappers quando for necessário distinguir ausente, nulo e zero.

## Testes Go

- Preferir table-driven tests quando isso melhorar clareza.
- Testar erros, context cancellation, timeout e concorrência quando aplicável.
- Rodar `go test -race` para código concorrente, exercitando os caminhos relevantes porque o detector só identifica races que ocorrem durante a execução.

## Ferramentas da linguagem

- Todo código deve estar formatado com `gofmt` ou `goimports`, conforme o padrão do projeto.
- `go test`, `go vet` e os linters configurados no projeto devem passar no escopo aplicável.
