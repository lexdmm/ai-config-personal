---
name: code-review
description: "Revisa somente o código alterado em PRs, branches, commits ou diffs e entrega achados priorizados com arquivo, linha comentável e texto pronto para o GitHub. Use automaticamente quando o usuário pedir code review, revisão de PR ou revisão de branch; não use para pedidos de implementação ou correção sem revisão."
---

# Code Review

Faça uma revisão somente leitura, seguindo as instruções globais e do projeto.

## Delimitação

1. Identifique a PR ou branch, o escopo funcional, eventuais restrições de
   arquivos e a decisão do usuário sobre executar testes.
2. Confirme o repositório, a branch atual e a base declarada pelo usuário.
3. Compare exatamente contra essa base e inclua alterações commitadas, staged e
   unstaged que pertençam à tarefa.
4. Não atribua à PR problemas preexistentes ou vindos da base. Se o diff
   contiver mudanças de outra tarefa ou branch paralela, reporte a contaminação
   sem reavaliar achados já apresentados separadamente.
5. Não altere código durante um pedido apenas de review.

Prefira comandos `git` somente leitura para descobrir histórico e diff. Nunca faça checkout, merge, rebase, reset, commit ou push sem autorização explícita para aquele comando.

## Revisão

Antes de concluir:

- Leia `AGENTS.md`, `CLAUDE.md`, as regras universais e da stack e a
  documentação especializada aplicável aos arquivos tocados.
- Verifique aderência à arquitetura existente antes de sugerir nova camada,
  abstração, trait, helper, service ou repository.
- Avalie performance de banco e aplicação: N+1, overfetch, consultas e
  contagens duplicadas, eager loading, paginação, índices, loops com I/O e
  processamento desnecessário.
- Verifique segurança, autenticação, autorização, isolamento por tenant ou
  organização, escopo dos dados, IDOR e enumeração de identificadores;
  respostas diferentes não devem revelar a existência de recursos inacessíveis.
- Procure métodos, consultas, resources, formatadores e regras já existentes
  antes de criar código equivalente; evite duplicação sem acoplar contextos
  delimitados apenas para eliminar poucas linhas semelhantes.
- Avalie SOLID e coesão de forma pragmática: responsabilidades claras,
  dependências na direção correta e ausência de abstrações especulativas.
- Revise `try/catch`: não engula exceções, não degrade silenciosamente dados
  obrigatórios, não continue usando transações inválidas e preserve contexto
  suficiente nos logs; falhas opcionais só podem degradar quando esse for o
  contrato explícito.
- Confira tipos, casts, nulabilidade, invariantes implícitas, ordenação
  determinística e tratamento de registros removidos ou concorrentes.
- Em endpoints, valide contrato de entrada e saída, paginação, códigos HTTP
  necessários, mascaramento seguro de `403`/`404` e consistência com OpenAPI.
- Revise comentários e PHPDoc: remova descrição óbvia ou redundante e mantenha
  apenas o motivo de decisões, invariantes e comportamentos não evidentes.
- Confira testes dos caminhos feliz, inválidos, vazios, limites, isolamento,
  autorização, concorrência e custo de queries conforme o risco da mudança. Se
  o usuário disser que outra pessoa já executou testes, Pint ou PHPStan, não os
  repita sem necessidade; ainda assim, revise a qualidade e a cobertura.
- Se o projeto usar `CODEOWNERS`, confira arquivos novos ou caminhos ainda sem
  cobertura e siga a organização e os responsáveis já adotados no repositório;
  não invente equipes, rótulos ou agrupamentos.
- Confirme cada pendência no diff e elimine falsos positivos.
- Não corrija pendências durante um pedido apenas de review. Quando o usuário
  autorizar ajustes, altere somente o necessário e revise o diff final para
  remover redundâncias introduzidas pela própria mudança.

## Linha para comentário

Para cada ajuste, informe uma linha atual que aceite comentário inline no diff do GitHub. Verifique isso no diff, não apenas no arquivo atual. Se a origem do problema estiver numa linha não alterada, escolha a linha alterada mais próxima que introduziu o comportamento e diga onde publicar o comentário.

Use link local absoluto clicável quando o arquivo estiver disponível:

```text
[Arquivo.ext (linha 123)](/caminho/absoluto/Arquivo.ext:123)
```

## Resposta

Use uma única seção chamada **Pendências técnicas** e ordene os itens por
prioridade (`P0`, `P1`, `P2`, `P3`). Classifique cada pendência como:

- **BUG CONFIRMADO:** comportamento incorreto ou violação de contrato
  comprovados no fluxo relevante;
- **PROBLEMA TÉCNICO:** problema concreto de arquitetura, manutenção, testes,
  documentação, performance ou qualidade sem comportamento funcional incorreto
  comprovado.

Se a evidência não for suficiente, não chame o caso de bug nem o apresente como
pendência confirmada; declare objetivamente a limitação.

Apresente cada pendência em um bloco sem marcador ou numeração. Na primeira
linha, use `**Problema encontrado — NATUREZA (PRIORIDADE):**`, seguido do link
para `Arquivo.ext:linha`, e termine a linha com `\` para forçar a quebra. Na
linha seguinte, reúna em um único parágrafo o comportamento observado, o impacto
concreto e a correção necessária, nessa ordem. Não crie o subtítulo **Impacto e
correção**. Separe os blocos com uma linha em branco.

Use linguagem natural, respeitosa e objetiva, como uma orientação técnica entre
desenvolvedores. Fale sobre o código, sem julgar ou atribuir intenção ao autor, e
inclua o contexto mínimo necessário sem soar burocrático ou seco. Para bug
confirmado, indique claramente a mudança necessária, preferindo `Para corrigir`.
Para problema técnico, calibre a orientação conforme a prioridade, sem tornar
opcional uma correção necessária. Não termine com pergunta e mencione teste
somente quando ele for necessário para proteger o cenário.

Evite sarcasmo, ironia, acusações, perguntas retóricas, elogios artificiais,
dramatização e expressões como `obviamente`, `simplesmente`, `foi feito errado`,
`o autor esqueceu`, `seria legal` ou `de repente`.

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
