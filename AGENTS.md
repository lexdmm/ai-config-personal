# Instruções globais de IA

Fonte única de instruções para agentes de IA (Claude Code, Codex CLI) em
qualquer projeto dentro de `~/development`. Este arquivo é referenciado via
symlink por `~/.claude/CLAUDE.md` e `~/.codex/AGENTS.md` — ver `setup.sh` e
`README.md` neste repo.

Preencha as seções abaixo aos poucos; deixe vazio o que ainda não se aplica.

## Identidade / perfil

<!-- Quem é o usuário, seu papel, contexto geral de trabalho. -->

## Convenções de código

<!-- Estilo, linguagens/stacks preferidas, padrões a seguir ou evitar. -->

## Preferências de workflow

<!-- Como prefere revisar código, granularidade de commits, uso de testes,
     nível de autonomia esperado do agente, etc. -->

### Autonomia para comandos git

- Comandos somente leitura (`status`, `diff`, `log`, `show`, `branch --list`,
  etc.) podem rodar direto, sem pedir confirmação.
- Qualquer comando que altere estado (`merge`, `push`, `rebase`, `reset`,
  `checkout` entre branches, criação/remoção de branch, commit não
  solicitado, etc.) precisa de confirmação explícita a cada vez — o usuário
  prefere rodar esses comandos ele mesmo, ou autorizar pontualmente.
- Uma concessão pontual ("pode rodar") vale só para aquele comando — não
  deve virar autorização geral para o resto da sessão, a menos que o
  usuário deixe isso claro.
- Em revisão de código (buscar branch/PR para comparar), preferir `git` a
  `gh`, mantendo a mesma regra de confirmação acima.

### Planejamento e execução em etapas

- Ao montar um plano de desenvolvimento: dividir em etapas pequenas e
  digeríveis para a carga cognitiva do usuário, explicando jargão técnico
  de forma leiga e breve (sem verbosidade).
- Ao executar um plano já alinhado: implementar uma etapa por vez e parar.
  Só avançar para a próxima quando o usuário digitar "next".

### Gate obrigatório de aceite por etapa

- Em cada etapa de análise, planejamento, implementação e validação, ler e
  aplicar integralmente todas as instruções compatíveis com o escopo:
  - as instruções globais deste `AGENTS.md`;
  - os critérios de `~/development/ai-config-personal/rules/universal.md`;
  - as regras específicas presentes em `~/development/ai-config-personal/rules/` para
    as linguagens, frameworks e tecnologias identificadas;
  - os arquivos `AGENTS.md`, `CLAUDE.md` e `CLAUDE.local.md` do projeto, quando
    existirem;
  - os documentos, contratos, decisões arquiteturais e convenções locais
    referenciados por essas fontes e relevantes para o trecho trabalhado.
- Essas fontes formam, em conjunto, os critérios obrigatórios de aceite.
  Nenhuma lista resumida neste arquivo substitui ou limita os critérios
  detalhados presentes nos documentos.
- Antes de concluir cada etapa, confrontar o resultado produzido com todos os
  critérios aplicáveis e corrigir as violações encontradas. Isso inclui, entre
  outros pontos, arquitetura e responsabilidades existentes, aplicação
  pragmática de SOLID, segurança e IDOR, performance, duplicação, tratamento de
  erros e `try/catch`, contratos, testes, efeitos colaterais e boas práticas da
  stack.
- Os pontos citados são exemplos recorrentes, não uma lista exaustiva. A IA deve
  identificar os demais critérios relevantes a partir das tecnologias, camadas,
  fluxos e riscos presentes no escopo.
- Não aplicar mecanicamente critérios incompatíveis com o contexto, mas também
  não descartar uma categoria sem antes verificar sua relevância no código e
  nas instruções ativas.
- Antes de criar regra, método ou abstração, procurar implementações equivalentes
  no projeto. Evitar duplicação real, mas só reutilizar ou extrair quando a
  responsabilidade e a semântica forem as mesmas; semelhança superficial não
  justifica abstração.
- A execução deste gate é obrigatória e silenciosa. Não reproduzir o checklist
  na resposta, salvo quando o usuário pedir. Uma etapa só pode ser apresentada
  como concluída depois dessa verificação.

### Uso de skills de code review

- Usar skills, checklists e o formato especializado de code review somente
  quando o usuário pedir explicitamente `review`, `code review`, revisão de PR,
  revisão de branch, revisão de commit ou revisão de diff.
- Pedidos pontuais para avaliar uma mensagem, decisão, trecho ou alteração já
  existente não devem ser ampliados para um code review completo. Nesses casos,
  responder apenas ao escopo solicitado e priorizar as orientações específicas
  dadas pelo usuário na conversa.

### Validação obrigatória de análises técnicas

- Nunca concluir que um bug existe, que uma causa procede ou que uma mudança
  está correta com base apenas em imagens, vídeos, descrições de terceiros,
  comentários de bots ou evidências visuais isoladas; esses materiais servem
  como pistas para orientar a investigação, não como comprovação suficiente.
- Antes de reportar um achado, rastrear no código o fluxo completo relevante,
  incluindo origem dos dados, estados, contratos, chamadas externas, tratamento
  de sucesso e falha e diferenças entre a base e a alteração analisada.
- Quando a inspeção estática não for suficiente, executar a validação mais
  aderente e segura disponível, como teste automatizado, reprodução controlada,
  chamada HTTP, consulta, logs ou instrumentação temporária, sem apresentar
  hipótese como fato confirmado.
- Se não for possível validar uma camada necessária, declarar objetivamente a
  limitação, separar sintoma confirmado de causa não comprovada e informar qual
  evidência falta; não registrar o caso como bug confirmado nem atribuir autoria
  à branch ou tarefa sem evidência no respectivo diff.

### Testes de tela no browser

- Ao validar uma tela ou fluxo interativo no navegador, usar e aplicar
  integralmente a skill `frontend-screen-browser-test`.

### Evidências de testes de backend

- Ao executar ou relatar uma validação de backend, usar e aplicar integralmente
  a skill `backend-test-evidence`.

### Relato de pendências técnicas (review, auditoria, pendências)

- Ao reportar problemas encontrados em código — review, auditoria de branch ou
  retomada de documento de pendências — usar uma única seção chamada
  **Pendências técnicas**, sem separar os itens por natureza.
- Classificar cada pendência como:
  - **BUG CONFIRMADO:** comportamento incorreto ou violação de contrato
    comprovados no fluxo relevante;
  - **PROBLEMA TÉCNICO:** problema concreto de arquitetura, manutenção, testes,
    documentação, performance ou qualidade sem comportamento funcional
    incorreto comprovado.
- Não chamar uma hipótese de bug. Quando faltar evidência para confirmar o
  comportamento ou a causa, declarar a limitação fora da lista de pendências.
- Apresentar cada pendência em um bloco sem marcador ou numeração. Na primeira
  linha, usar `**Problema encontrado — NATUREZA (PRIORIDADE):**`, seguido do link
  para `Arquivo.ext:linha`, e terminar a linha com `\` para forçar a quebra.
- Na linha seguinte, reunir em um único parágrafo o comportamento observado, o
  impacto concreto e a correção necessária, nessa ordem. Não criar o subtítulo
  **Impacto e correção**.
- Separar blocos consecutivos com uma linha em branco.
- Ordenar as pendências por prioridade (`P0`, `P1`, `P2`, `P3`). Não incluir
  veredito, pontos aprovados, categorias vazias, elogios ou resumo final.
- Escrever como uma orientação técnica entre desenvolvedores: linguagem natural,
  respeitosa e objetiva, sempre sobre o código, sem julgar ou atribuir intenção
  ao autor. Explicar o contexto mínimo necessário sem soar burocrático ou seco.
- Para bug confirmado, indicar a mudança necessária com clareza, preferindo
  `Para corrigir`. Para problema técnico, calibrar a orientação conforme a
  prioridade, sem transformar correção necessária em sugestão opcional.
- Evitar sarcasmo, ironia, acusações, perguntas retóricas, elogios artificiais,
  dramatização e expressões como `obviamente`, `simplesmente`, `foi feito errado`,
  `o autor esqueceu`, `seria legal` ou `de repente`.
- Se não houver pendências, responder apenas `Nenhuma pendência técnica encontrada.`

Modelo:

```text
## Pendências técnicas

**Problema encontrado — BUG CONFIRMADO (P1):** [Arquivo.ext:123](/caminho/absoluto/Arquivo.ext:123)\
Nesse ponto, <comportamento comprovado>. Com isso, <impacto concreto>. Para corrigir, <ação necessária>.

**Problema encontrado — PROBLEMA TÉCNICO (P2):** [OutroArquivo.ext:45](/caminho/absoluto/OutroArquivo.ext:45)\
Aqui, <problema concreto sem bug comprovado>. Isso <impacto atual ou futuro>. Nesse caso, <ajuste recomendado ou necessário>.
```

### Projetos que usam Laravel Sail

- Quando um projeto PHP/Laravel adotar `vendor/bin/sail`, executar por ele os
  comandos PHP, Artisan e testes; não assumir que existe PHP instalado
  diretamente no host.
- Não impor o Sail a projetos que não o utilizam; nesses casos, seguir as
  ferramentas e convenções locais.
- O sandbox do agente pode bloquear `/var/run/docker.sock` e fazer o Sail
  informar incorretamente que Docker/Podman não está rodando, mesmo com os
  containers ativos.
- Quando isso acontecer, verificar o acesso com `docker ps`. Se houver
  `permission denied` no socket, repetir imediatamente o comando do Sail com
  acesso escalado ao Docker, em vez de pedir ao usuário para iniciar ou
  explicar novamente o ambiente.

## Critérios de aceite técnico

Antes de revisar, sugerir ou gerar código, ler e aplicar integralmente
`~/development/ai-config-personal/rules/universal.md`. Essas regras são critérios de
aceite obrigatórios, não exemplos opcionais.

Identificar a stack presente no escopo e ler também o arquivo correspondente,
quando aplicável:

- TypeScript, React ou NestJS:
  `~/development/ai-config-personal/rules/typescript-react-nestjs.md`;
- Go: `~/development/ai-config-personal/rules/go.md`;
- PHP ou Laravel: `~/development/ai-config-personal/rules/php-laravel.md`.

Aplicar apenas os arquivos compatíveis com as tecnologias realmente presentes.

## Projetos específicos

Cada repo pode ter seu próprio `AGENTS.md` (Codex) / `CLAUDE.md` (Claude Code)
na raiz para contexto específico (stack, arquitetura). Isso é somado a este
arquivo automaticamente — não precisa referenciar nada manualmente.
