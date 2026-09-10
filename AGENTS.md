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

### Comunicação e uso de contexto

- Ser conciso e não repetir o pedido, a mesma constatação, justificativa ou
  correção em mensagens consecutivas. Uma atualização deve acrescentar
  informação verificável ou indicar mudança real de estado.
- Ler e exibir somente os arquivos, trechos e saídas necessários à decisão
  atual. Não carregar o catálogo completo quando o roteamento permitir seções
  específicas, nem repetir leituras sem mudança relevante no conteúdo.
- Evitar elogios automáticos, frases de preenchimento e narração do raciocínio.
  Informar diretamente o que foi confirmado, o que falta e qual ação está em
  andamento.

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
- Ao apresentar um plano de desenvolvimento, incluir uma sugestão de nome de
  branch em inglês antes das etapas. Usar letras minúsculas e `kebab-case`, no
  formato `<tipo>/<ticket>-<descrição>`, como
  `feature/DEV-7183-pre-boarding-journey`. Escolher o tipo conforme a natureza
  da mudança, como `feature`, `fix`, `refactor`, `chore`, `test` ou `docs`.
- Usar o identificador informado pelo usuário ou disponível no contexto; nunca
  inventar um ticket. Quando não houver identificador, usar
  `<tipo>/<descrição>`. Respeitar uma convenção mais específica do projeto,
  quando existir.
- Ao executar um plano já alinhado: implementar uma etapa por vez e parar.
  Só avançar para a próxima quando o usuário digitar "next".
- Ao concluir cada etapa de desenvolvimento, encerrar a resposta com uma única
  sugestão de mensagem de commit, sempre em inglês e limitada às alterações
  daquela etapa. Seguir a convenção de commits do projeto; quando ela não
  existir, preferir Conventional Commits, com descrição curta e no imperativo.
- Apresentar a sugestão na última linha com o rótulo `Suggested commit:` e a
  mensagem em código inline para facilitar sua cópia, como
  Suggested commit: `feat: add pre-boarding journey`. Não usar bloco de código
  nem acrescentar explicação nessa linha. Sugerir branch ou mensagem não
  autoriza criar branch nem executar commit; essas ações continuam exigindo
  confirmação explícita.

### Gate obrigatório de aceite por etapa

- No início de cada etapa, identificar as instruções aplicáveis entre este
  `AGENTS.md`, as regras universais e da stack e os documentos locais do
  projeto. Essas fontes formam em conjunto os critérios obrigatórios de aceite;
  nenhuma lista resumida as substitui ou limita.
- Antes de concluir uma etapa que alterou arquivos, inspecionar o resultado real
  da etapa, não a intenção lembrada:
  1. executar `git status --short`, `git diff` e `git diff --cached`;
  2. ler também o conteúdo dos arquivos novos ainda não rastreados;
  3. separar as alterações da etapa de mudanças preexistentes do usuário;
  4. reabrir somente as seções das regras e dos documentos relacionadas aos
     arquivos, camadas, fluxos e riscos efetivamente tocados;
  5. confrontar essas regras com as linhas reais alteradas e corrigir qualquer
     violação antes de apresentar a etapa como concluída;
  6. executar
     `~/development/ai-config-personal/scripts/verify-stage.sh -- <caminhos>`
     apenas para os arquivos da etapa, usando `--all` somente quando todas as
     alterações pendentes pertencerem ao mesmo trabalho.
- Quando não houver repositório Git, fazer a mesma conferência diretamente nos
  arquivos alterados. Ter lido uma regra no começo da sessão ou conseguir
  citá-la de memória não substitui confrontá-la com o resultado atual.
- Executar as validações proporcionais ao risco e ao escopo da etapa. Não
  repetir testes ou verificações sem necessidade quando nenhuma mudança nova
  puder afetar seus resultados.
- O gate é obrigatório e silencioso quando tudo estiver correto. Se alguma
  parte relevante não puder ser verificada, declarar a limitação; silêncio não
  pode ser usado para afirmar uma validação que não ocorreu.
- Só apresentar a etapa como concluída e escrever `Suggested commit:` depois
  desse fechamento. Não reproduzir o procedimento na resposta, salvo quando o
  usuário pedir.

### Uso de skills de code review

- Usar skills, checklists e o formato especializado de code review somente
  quando o usuário pedir explicitamente `review`, `code review`, revisão de PR,
  revisão de branch, revisão de commit ou revisão de diff.
- Pedidos pontuais para avaliar uma mensagem, decisão, trecho ou alteração já
  existente não devem ser ampliados para um code review completo. Nesses casos,
  responder apenas ao escopo solicitado e priorizar as orientações específicas
  dadas pelo usuário na conversa.

### Escopo de execução em code review

- Todo code review deve ser exclusivamente uma análise estática e somente
  leitura do código, do diff, dos contratos e do fluxo relevante.
- Durante um code review, usar apenas comandos de leitura necessários para
  localizar e inspecionar repositório, histórico, arquivos e referências. Não
  executar aplicação, testes, builds, linters, formatadores, analisadores
  estáticos, migrations, chamadas HTTP, consultas a banco ou logs, fluxos no
  navegador nem instrumentação.
- Avaliar a qualidade e a cobertura dos testes pelo código dos próprios testes,
  sem executá-los. Quando o código e o fluxo disponível não bastarem para
  comprovar uma conclusão, declarar a limitação e a evidência faltante; não
  ampliar o review para uma tarefa de validação dinâmica.

### Validação obrigatória de análises técnicas

- Nunca concluir que um bug existe, que uma causa procede ou que uma mudança
  está correta com base apenas em imagens, vídeos, descrições de terceiros,
  comentários de bots ou evidências visuais isoladas; esses materiais servem
  como pistas para orientar a investigação, não como comprovação suficiente.
- Antes de reportar um achado, rastrear no código o fluxo completo relevante,
  incluindo origem dos dados, estados, contratos, chamadas externas, tratamento
  de sucesso e falha e diferenças entre a base e a alteração analisada.
- Fora de code review, quando a inspeção estática não for suficiente, executar a
  validação mais aderente e segura disponível, como teste automatizado,
  reprodução controlada, chamada HTTP, consulta, logs ou instrumentação
  temporária, sem apresentar hipótese como fato confirmado.
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

- Ao reportar problemas em review, auditoria ou retomada de pendências, aplicar
  integralmente a seção `Formato obrigatório de resposta do review` do catálogo
  técnico e a seção `Resposta` da skill de code review aplicável.
- Essas fontes preservam a classificação entre bug confirmado e problema
  técnico, prioridades, evidência, estrutura dos blocos, linguagem respeitosa e
  o formato pronto para comentário. Não substituir suas regras por um resumo
  lembrado nem improvisar outro formato.

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

Antes de analisar, revisar, sugerir ou gerar código, ler e aplicar integralmente
`~/development/ai-config-personal/rules/universal.md`. O arquivo contém o núcleo
obrigatório e o roteamento para o catálogo detalhado em
`~/development/ai-config-personal/references/technical-acceptance/catalog.md`.

Identificar todos os módulos aplicáveis pelos arquivos, camadas, fluxos e riscos
do trabalho e ler integralmente as respectivas seções do catálogo antes de
atuar. Uma tarefa pode exigir vários módulos; na dúvida razoável, incluir a
seção. O carregamento seletivo reduz contexto, mas não torna nenhum critério
aplicável opcional.

Identificar a stack presente no escopo e ler também o arquivo correspondente,
quando aplicável:

- TypeScript, React ou NestJS:
  `~/development/ai-config-personal/rules/typescript-react-nestjs.md`;
- Go: `~/development/ai-config-personal/rules/go.md`;
- PHP ou Laravel: `~/development/ai-config-personal/rules/php-laravel.md`.

Aplicar apenas os arquivos de stack compatíveis com as tecnologias realmente
presentes, sem limitar os módulos universais exigidos pelo contexto.

## Projetos específicos

Cada repo pode ter seu próprio `AGENTS.md` (Codex) / `CLAUDE.md` (Claude Code)
na raiz para contexto específico (stack, arquitetura). Isso é somado a este
arquivo automaticamente — não precisa referenciar nada manualmente.
