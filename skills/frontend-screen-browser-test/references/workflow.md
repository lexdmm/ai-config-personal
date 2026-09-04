# Workflow de teste de tela no browser

Use este contexto para validar qualquer mudança de tela no frontend que
exija checagem interativa no navegador — formulário, listagem, aba,
condicional por feature flag, estado vazio/erro/loading etc. — gerando
evidência visual do resultado. Não é específico de nenhuma tela ou feature;
o exemplo de template abaixo é só ilustrativo.

## Entrada esperada

- Arquivo(s) ou tela alterada.
- Fluxo a validar (happy path e, se relevante, erro/validação/estado vazio).
- Ambiente já rodando ou instrução para subir localmente.

## Preparação obrigatória do ambiente e dos dados

O teste de browser deve exercitar pré-condições válidas do fluxo. Ausência de
seed, feature flag ou acesso a uma integração não basta, por si só, para marcar
um cenário como não testável.

> **REGRA OBRIGATÓRIA — SOMENTE AMBIENTE LOCAL:** toda preparação descrita nesta
> seção — criação ou alteração de seeds, massa sintética, feature flags, mocks,
> fakes, stubs, emuladores, containers e overrides — só pode ser executada no
> ambiente local. Nunca execute essa preparação em homologação, staging,
> produção ou qualquer ambiente remoto/compartilhado. Se um teste não local não
> possuir as pré-condições necessárias, use somente o que já estiver disponível
> e autorizado nesse ambiente ou registre o cenário como não executado, com a
> limitação; não tente contorná-la modificando dados ou infraestrutura.

1. Rastreie o fluxo ponta a ponta antes de abrir o browser: tela, chamadas de
   API, regra de autorização, feature flags, persistência, filas e integrações
   externas relevantes.
2. Localize em `~/development` os projetos de backend envolvidos, leia as
   instruções de cada projeto e use seus mecanismos oficiais sempre que
   existirem: factory, seeder, command, endpoint, fixture ou helper de teste.
   Não troque a branch desses projetos sem autorização explícita.
3. Crie a menor massa local capaz de provar o cenário e suas relações reais.
   Não basta um registro aparecer numa lista: confirme pela API, banco ou regra
   da aplicação que ele atende às mesmas pré-condições exigidas pela tela de
   detalhe ou pela ação seguinte.
4. Para feature flags, consulte primeiro o mecanismo usado pela aplicação. No
   ambiente local, habilite a flag existente ou cadastre a chave ausente com o
   menor escopo necessário para o ator/empresa do teste; não crie migration nem
   altere defaults de outros ambientes apenas para preparar a validação.
5. Quando uma dependência externa não estiver disponível, escolha a substituição
   mais fiel e simples para o contrato exercitado:
   - fake/stub já fornecido pelo projeto;
   - mock temporário na fronteira HTTP, SDK, fila ou storage;
   - emulador local em container quando isso aumentar materialmente a fidelidade,
     como um storage compatível com S3/GCS para upload, download, headers,
     conteúdo binário, expiração e respostas de erro.
6. O substituto deve reproduzir os aspectos observados pela tela — status,
   payload, headers, tipo e tamanho do arquivo, latência ou falha relevante — e
   nunca pode ser apresentado como prova de comunicação com o serviço externo
   real. Use sandbox real somente quando houver credencial, autorização e
   segurança para isso.
7. Prefira overrides, fixtures e recursos temporários fora do código produtivo.
   Se for indispensável instrumentar ou mockar código/configuração localmente,
   mantenha a mudança mínima, não faça commit e registre exatamente o que foi
   substituído.
8. Não enfraqueça autenticação ou autorização globalmente, não copie segredos de
   outros ambientes e não exponha dados pessoais nas massas, logs, screenshots
   ou relatórios.
9. Ao terminar, remova somente seeds, flags, arquivos, mocks e containers que o
   próprio teste criou, preservando integralmente o estado e as alterações
   preexistentes do usuário. Se a remoção segura não puder ser garantida,
   informe os recursos deixados e como identificá-los.

## Como testar

1. Identifique os testes unitários que cobrem os arquivos alterados da tela
   (componente, hook, formulário, etc.) e rode **apenas esses** — não a
   suíte inteira nem uma varredura de regressão em arquivos vizinhos.
2. Prepare e confira as pré-condições conforme a seção anterior. Registre os
   projetos envolvidos, a massa criada, as flags habilitadas e qualquer mock ou
   emulador usado, sem expor segredos ou dados pessoais.
3. Só depois dos unitários passarem, valide a tela no navegador: suba/abra o
   app, exercite o fluxo real (happy path e casos de borda relevantes —
   loading, erro, vazio, permissão, feature flag) e capture evidência visual
   (screenshot) de cada estado relevante.
4. Se o projeto não tiver ferramenta dedicada de screenshot/E2E configurada
   (Playwright, Puppeteer, Cypress, MCP de browser), diga isso explicitamente
   e caia no fallback padrão de browser interativo (ex.: skill `/run`), em vez
   de simular ou assumir uma ferramenta que não existe no projeto.
5. Teste unitário e teste de browser são complementares aqui, não
   substitutos um do outro — não declare a mudança validada só com um dos
   dois.
6. Mover/copiar os screenshots finais do scratchpad temporário para
   `~/Downloads/{TICKET-ID}-evidencias/` (criar a pasta se não existir),
   renomeados de forma numerada e descritiva — nunca deixar a evidência só
   em `/tmp/...`, que é efêmero e o usuário não sabe localizar.
7. Remova a preparação temporária criada pelo teste conforme as regras da seção
   anterior e registre qualquer recurso que precise permanecer para reprodução.

## Formato obrigatório da resposta

Este é o único fluxo com exceção ao padrão curto de resposta de chat: o
objetivo aqui é gerar um relatório de evidência pronto para colar direto na
tarefa do Jira, então a resposta final segue este modelo, um bloco por
cenário testado, nesta ordem:

```markdown
# {TICKET-ID} — Evidências de teste

**Ambiente:** {Local | Homolog | ...}
**Feature flag:** {Ativada | Desativada | N/A}
**Automação:** {ferramenta usada, ex.: Playwright com Chrome headless}
**Preparação local:** {seed/factory/flag/mock/emulador usado, quando aplicável}
**Resultado geral:** {✅ Aprovado | ✅ Aprovado com ressalva em ... | ❌ Reprovado}

---

## 1. {Nome do cenário} — {Perfil/Ator, quando fizer sentido}

**Cenário:** {o que foi exercitado}
{Campos de contexto relevantes ao cenário, quando fizer sentido — ex.: **Entidade:**, **ID:**, **Contexto:**}

**Resultado obtido:**
- ✅ {comportamento verificado, um por linha}
- ❌ {comportamento que falhou, se houver}

**Resposta validada:** (só quando o cenário expõe dado de API/negócio a conferir)
- {Campo}: `{valor}`

**Evidência:**
🖼 {/home/usuario/Downloads/TICKET-ID-evidencias/NN-nome-do-cenario.png}

---

## 2. {Próximo cenário}
...
```

Regras do modelo:

- Numerar os cenários na ordem testada; nomear cada um pelo comportamento
  exercitado e, quando aplicável, pelo perfil/ator envolvido.
- Cada item de "Resultado obtido" é uma checagem objetiva e verificável, uma
  por linha — não juntar duas checagens na mesma linha.
- "Resposta validada" só aparece quando há dado concreto de API/negócio a
  registrar (contagens, datas, status); valores em `código inline`.
- Todo cenário termina com "Evidência:" apontando para o screenshot daquele
  passo, numerado na mesma ordem do cenário (`01-...`, `02-...`) e **sempre
  com o caminho absoluto do arquivo já em `~/Downloads/{TICKET-ID}-evidencias/`**
  (ver passo 6 de "Como testar"), não o caminho do scratchpad e não só o
  nome — quem lê o relatório precisa conseguir localizar e anexar o arquivo
  no Jira sem perguntar onde ele está.
- "Resultado geral" resume aprovação/ressalva/reprovação logo no topo, antes
  dos cenários — não deixar para o fim.
- "Preparação local" deve distinguir dados reais locais de mocks/emuladores e
  delimitar o que não foi validado contra uma integração externa real; omita o
  campo quando nenhuma preparação adicional tiver sido necessária.

Fora deste fluxo de evidência para Jira, vale o padrão curto de resposta
(sem tabelas, sem seções numeradas, sem resumo repetido).
