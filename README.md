# ai-config-personal

Configuração de IA compartilhada entre todos os projetos em `~/development`,
para Claude Code e Codex CLI.

## Como funciona

- `AGENTS.md` é a fonte única de instruções globais (identidade, convenções,
  preferências de workflow).
- `setup.sh` cria symlinks que fazem `~/.codex/AGENTS.md` e
  `~/.claude/CLAUDE.md` apontarem para o `AGENTS.md` deste repo. Como os dois
  são carregados por padrão em toda sessão (Codex e Claude Code têm suporte
  nativo a config global), qualquer projeto novo em `~/development/<repo>/`
  já herda essas instruções automaticamente — não precisa referenciar nada
  manualmente por projeto.
- Para o Claude Code, `setup.sh` também faz `~/.claude/rules` apontar para
  `rules/`. Assim, os critérios universais entram no contexto pelo mecanismo
  nativo do Claude, enquanto as regras de stack são carregadas somente quando
  os caminhos declarados no frontmatter forem relevantes.
- `skills/` é a fonte neutra das skills reutilizáveis pelo Claude Code e pelo
  Codex. `setup.sh` expõe a mesma fonte em `~/.claude/skills` e linka cada skill
  em `~/.agents/skills`, o diretório pessoal oficial do Codex. Também mantém
  links em `~/.codex/skills` para compatibilidade com instalações anteriores.
  Cada skill mantém suas instruções em `SKILL.md`, materiais auxiliares em
  `references/` e metadados específicos do Codex em `agents/openai.yaml`,
  quando aplicável.
- `claude/agents/` e `claude/commands/` guardam subagents e comandos específicos
  do Claude Code e são linkados em `~/.claude/{agents,commands}`.
- `rules/` guarda os critérios de aceite técnico (code review) usados como
  regra obrigatória, não como exemplo:
  - `rules/universal.md` — critérios universais (Definition of Done,
    severidade/prioridade, segurança, multi-tenancy, testes, performance,
    catálogo de padrões arquiteturais etc.). No Claude, o arquivo é carregado
    como regra global; no Codex, o `AGENTS.md` exige sua leitura integral antes
    de revisar, sugerir ou gerar código.
  - `rules/typescript-react-nestjs.md`, `rules/go.md`, `rules/php-laravel.md`
    — regras adicionais por stack. O Claude usa o escopo de caminhos declarado
    em cada arquivo, e o Codex detecta as tecnologias presentes conforme as
    instruções do `AGENTS.md`.
- `skills/code-review/` concentra o processo e o checklist de code
  review, com arquivo, linha comentável do diff e texto pronto para o GitHub.
  A skill é carregada automaticamente quando o pedido for um code review e pode
  ser chamada explicitamente como `/code-review` no Claude ou
  `$code-review` no Codex.
- `skills/frontend-screen-browser-test/` concentra a validação de telas
  no browser (formulário, listagem, aba, feature flag etc.), incluindo preparo
  local, testes relacionados e evidência visual pronta para o Jira. O workflow
  detalhado fica autocontido em `references/workflow.md` dentro da skill.
- `skills/backend-test-evidence/` concentra a validação de mudanças de
  backend pela interface mais aderente e produz evidências prontas para o Jira.
  O workflow detalhado fica autocontido em `references/workflow.md` dentro da
  skill.

## Uso

Na primeira instalação, execute:

```bash
./setup.sh
```

Para conferir a instalação sem alterar arquivos ou links:

```bash
./setup.sh --check
```

O script retorna erro quando encontra um arquivo real em conflito, um link
incorreto ou uma skill órfã. Esses conflitos precisam ser resolvidos
manualmente; o instalador não remove conteúdo automaticamente.

Como esses caminhos globais aceitam apenas um destino, executar `setup.sh` em
outro repositório de configuração troca o perfil ativo. Revise o destino dos
links com `./setup.sh --check` antes de iniciar uma sessão importante.

Para validar a estrutura do repositório, os arquivos Markdown, os pacotes de
skill, seus metadados e sinais comuns de conteúdo sensível:

```bash
./validate.sh
```

Para incluir na mesma validação os symlinks instalados nos diretórios pessoais:

```bash
./validate.sh --installed
```

Editar arquivos já existentes em `AGENTS.md`, `skills/` ou `claude/` reflete
nas sessões novas sem precisar copiar nada. Ao criar ou remover uma skill, rode
`./setup.sh` novamente para atualizar ou detectar seus links individuais.

## Segurança antes de publicar

- Execute `./validate.sh` antes de cada publicação. A validação bloqueia nomes
  de arquivos sensíveis e padrões comuns de segredos sem exibir seus valores.
- Para procurar nomes de clientes, empresas ou projetos que só você conhece,
  crie `.publication-denylist.local` com um termo literal por linha. O arquivo é
  ignorado pelo Git, e a validação informa somente os caminhos encontrados.
- Mantenha configurações específicas de empresas ou clientes em outro
  repositório ou diretório privado, sem aninhá-las nesta cópia pessoal.
- Ative a detecção de segredos e a proteção de push no provedor Git como uma
  camada adicional; a validação local não substitui esses controles.
- Revise o diff antes de atualizar os symlinks. Este repositório controla
  instruções globais dos agentes e, portanto, deve ser tratado como código
  confiável.

## Contexto específico de um projeto

Se um repo precisar de instruções próprias, crie `AGENTS.md` para o Codex e
`CLAUDE.md` para o Claude Code na raiz do projeto. Para manter uma única fonte
local, um deles pode ser um symlink relativo para o outro. Cada agente combina
automaticamente suas instruções globais com o arquivo correspondente do projeto.

As regras universais e as regras específicas de TypeScript/React/NestJS, Go ou
PHP/Laravel são selecionadas pelas instruções globais conforme as tecnologias
presentes. O arquivo do projeto só precisa registrar particularidades da sua
arquitetura, domínio, comandos ou convenções locais.
