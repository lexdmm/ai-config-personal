# Workflow de teste de backend

Use este contexto sempre que uma mudança de backend for exercitada ou quando o
usuário pedir um relatório de validação pronto para o Jira. O objetivo é provar
o comportamento pela interface mais aderente ao desenvolvimento, sem presumir
que todo backend possui ou precisa de um endpoint HTTP.

## Princípio de escolha da evidência

Antes de testar, identifique a superfície alterada e escolha o mecanismo que
exercita o maior trecho real do fluxo com segurança:

| Superfície principal | Evidência preferencial |
|---|---|
| Endpoint HTTP/API | Chamada real com `curl` ou cliente equivalente, incluindo método, rota, entrada, status e campos relevantes da resposta |
| Repository/consulta | Consulta pela aplicação ou banco, registros relevantes e, quando aplicável, quantidade/plano de queries |
| Escrita/persistência | Entrada da operação e estado relevante antes/depois, incluindo isolamento e efeitos colaterais esperados |
| Command/CLI | Comando executado, argumentos, exit code, saída relevante e efeito persistido |
| Job/fila/evento | Disparo, processamento, estado final, tentativas/erros e efeitos observáveis |
| Integração externa | Sandbox real quando autorizado; caso contrário fake, stub, mock ou teste de contrato, deixando explícito o limite |
| Serviço/regra de negócio | Entrada/saída observável e testes automatizados da regra e dos casos de borda relevantes |
| Migration/schema | Estado do schema, execução da migration e compatibilidade; rollback somente quando seguro e autorizado |

Quando existe serviço HTTP acessível e é seguro chamá-lo, execute também a
validação real com `curl` ou cliente equivalente. A chamada HTTP complementa os
testes automatizados, consultas de banco e demais evidências pertinentes; não
deve ser tratada como alternativa que dispensa essas verificações. Ela deixa de
ser obrigatória quando a mudança não expõe serviço HTTP, o ambiente está
indisponível ou a chamada exige efeito externo/destrutivo sem autorização.

## Como testar

1. Delimite o teste ao escopo da tarefa e leia as instruções do projeto.
2. Registre ambiente, branch/commit quando disponível, ator autenticado e
   pré-condições relevantes. Não exponha credenciais ou dados pessoais.
3. Prepare ou localize a menor massa capaz de provar os casos. Identifique IDs e
   relações úteis para reprodução, mas masque dados sensíveis.
4. Exercite o caminho feliz e os casos adicionais proporcionais ao risco:
   entrada inválida, vazio/nulo, autorização, isolamento entre tenants,
   ordenação, concorrência, idempotência, erro externo e limites.
5. Confira o contrato observável: status/exit code, tipos, valores, ordenação,
   paginação, persistência, efeitos colaterais, logs e custo de queries conforme
   o que a mudança promete.
6. Se houver endpoint HTTP acessível e seguro dentro do escopo, valide-o também
   com `curl` ou cliente equivalente, mesmo quando já existirem testes
   automatizados; registre método, rota, entrada, status e retorno relevante.
7. Rode apenas os testes automatizados relacionados à mudança. Não chame teste
   de `Feature`/integração de unitário; informe o tipo real.
8. Compare esperado e obtido. Uma checagem só recebe `✅ Passou` quando foi
   efetivamente observada. Use `❌ Falhou` para divergência e `⚠️ Não executado`
   para uma limitação, com o motivo e a evidência substituta utilizada.
9. Revise o relatório para remover tokens, senhas, cookies, chaves, headers
   sensíveis e payloads desnecessários antes de entregá-lo.

## Quando o fluxo real não puder ser exercitado

- Explique objetivamente o bloqueio: serviço indisponível, integração sem
  sandbox, ausência de credencial, dependência externa ou risco destrutivo.
- Use a evidência substituta mais forte disponível, nesta ordem aproximada:
  teste de integração/contrato, teste automatizado da camada, execução local
  isolada, consulta de estado ou inspeção estática.
- Não invente retorno nem declare sucesso do fluxo não executado. Se uma parte
  relevante ficou descoberta, use `✅ Aprovado com ressalva` ou `❌ Reprovado`
  no resultado geral, conforme o impacto.
- Omitir uma seção sem relação com a mudança é correto; não preencher o
  relatório com `N/A` apenas para completar o template.

## Formato obrigatório da resposta

Adapte os rótulos à superfície testada (`Serviço`, `Consulta`, `Comando`,
`Job`, `Evento` ou `Operação`). Preserve a ordem geral abaixo e omita blocos
que não se aplicam.

````markdown
# {TICKET-ID} — Evidências de teste de backend

**Ambiente:** {Local | Homolog | ...}
**Branch/commit:** {referência testada, quando disponível}
**Escopo:** {comportamento validado}
**Mecanismo:** {curl | consulta de banco | command | job | testes | ...}
**Resultado geral:** {✅ Aprovado | ✅ Aprovado com ressalva | ❌ Reprovado}

## Massa e pré-condições

- {ator, entidade, IDs e relações relevantes, sem segredos}
- {estado inicial necessário}

## 1. {Nome do cenário}

**Cenário:** {comportamento exercitado}

**Serviço/consulta/comando/operação:**
```text
{método e rota, SQL/consulta, comando, job ou chamada executada}
```

**Entrada:**
```json
{path/query params, body, argumentos ou estado de entrada relevante}
```

**Resultado esperado:**
- {contrato ou efeito esperado}

**Resultado obtido:**
- ✅ Passou — {checagem objetiva observada}
- ❌ Falhou — {divergência, quando houver}
- ⚠️ Não executado — {limitação, quando houver}

**Retorno/estado observado:**
```json
{somente campos ou registros relevantes}
```

## Testes automatizados

| Status | Tipo | Teste | Validação | Resultado |
|---|---|---|---|---|
| ✅ Passou | {Unitário/Integração/Feature/Contrato/E2E/...} | `{nome}` | {o que prova} | {assertions, queries, exit code ou outro resultado} |

## Validações complementares

- ✅ Passou — {autorização, isolamento, queries, idempotência, logs etc.}

## Limitações e ressalvas

- ⚠️ {parte não exercitada, motivo e evidência substituta}
````

## Regras do relatório

- Coloque o resultado geral no topo e um status explícito em cada cenário.
- Em GET sem body, trate path params e query params como entrada/payload do
  teste. Em banco, use como entrada os filtros e o estado inicial relevante.
- Mostre o retorno integral somente quando ele for pequeno e necessário; em
  geral, registre apenas os campos que provam o critério de aceite.
- Separe resultado esperado de resultado obtido para tornar divergências
  visíveis.
- Na tabela automatizada, uma linha representa um teste ou grupo homogêneo de
  testes. Preserve o nome real e a classificação real da suíte.
- Inclua performance, segurança, isolamento, persistência, logs ou contrato
  apenas quando forem relevantes ao risco e ao escopo da mudança.
- Se nenhum teste automatizado existir ou puder ser executado, substitua a
  tabela por uma ressalva objetiva; não crie testes fictícios.
- Evidência de banco deve registrar somente colunas necessárias e nunca copiar
  dados pessoais ou segredos para o Jira.
- Operações destrutivas, ambientes compartilhados e integrações externas
  continuam sujeitos à autorização do usuário e às regras de segurança do
  projeto; este workflow não amplia permissões.
