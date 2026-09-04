#!/usr/bin/env bash
# Validates the publishable repository structure and, optionally, its installation.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHECK_INSTALLED=false
failures=0

usage() {
  echo "Uso: $0 [--installed]"
  echo "  --installed  Valida também os symlinks nos diretórios pessoais."
}

fail() {
  echo "ERRO: $1" >&2
  failures=$((failures + 1))
}

case "${1:-}" in
  "") ;;
  --installed) CHECK_INSTALLED=true ;;
  -h|--help)
    usage
    exit 0
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac

if [ "$#" -gt 1 ]; then
  usage >&2
  exit 2
fi

validate_required_paths() {
  local required_path
  local required_paths=(
    .gitignore
    AGENTS.md
    LICENSE
    README.md
    setup.sh
    rules/universal.md
    rules/typescript-react-nestjs.md
    rules/go.md
    rules/php-laravel.md
    skills
    claude/agents
    claude/commands
  )

  for required_path in "${required_paths[@]}"; do
    if [ ! -e "$ROOT/$required_path" ]; then
      fail "caminho obrigatório ausente: $required_path"
    fi
  done

  if [ -e "$ROOT/workflows" ]; then
    fail "diretório legado presente: workflows/"
  fi

  if [ -e "$ROOT/claude/skills" ] || [ -L "$ROOT/claude/skills" ]; then
    fail "alias legado presente: claude/skills; use somente skills/"
  fi
}

validate_publication_safety() {
  local sensitive_path matched_path term
  local denylist="$ROOT/.publication-denylist.local"
  local sensitive_patterns=(
    '.env'
    '.env.*'
    '*.pem'
    '*.key'
    '*.p12'
    '*.pfx'
    '*credentials*'
    '*secret*'
  )

  for sensitive_path in "${sensitive_patterns[@]}"; do
    while IFS= read -r -d '' matched_path; do
      if [ "${matched_path#"$ROOT/"}" = ".env.example" ]; then
        continue
      fi
      fail "arquivo potencialmente sensível: ${matched_path#"$ROOT/"}"
    done < <(find "$ROOT" -path "$ROOT/.git" -prune -o -type f -name "$sensitive_path" -print0)
  done

  while IFS= read -r matched_path; do
    [ -n "$matched_path" ] || continue
    fail "possível segredo encontrado em: ${matched_path#"$ROOT/"}"
  done < <(grep -ERIl \
    --exclude-dir=.git \
    --exclude='.publication-denylist.local' \
    --exclude='validate.sh' \
    --exclude='*.md' \
    --exclude='*.example' \
    -- '(BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY|AKIA[0-9A-Z]{16}|gh[pousr]_[A-Za-z0-9_]{20,}|github_pat_[A-Za-z0-9_]{20,}|sk-[A-Za-z0-9_-]{20,}|xox[baprs]-[A-Za-z0-9-]{10,}|(password|passwd|api[_-]?key|secret|token)[[:space:]]*[:=][[:space:]]*["'"'][^"'"']{8,}["'"'])' \
    "$ROOT" 2>/dev/null || true)

  if [ -f "$denylist" ]; then
    while IFS= read -r term || [ -n "$term" ]; do
      case "$term" in
        ''|'#'*) continue ;;
      esac

      while IFS= read -r matched_path; do
        [ -n "$matched_path" ] || continue
        fail "termo privado encontrado em: ${matched_path#"$ROOT/"}"
      done < <(grep -FRIl \
        --exclude-dir=.git \
        --exclude='.publication-denylist.local' \
        -- "$term" "$ROOT" 2>/dev/null || true)
    done < "$denylist"
  fi
}

validate_shell_scripts() {
  local shell_script

  while IFS= read -r -d '' shell_script; do
    if ! bash -n "$shell_script"; then
      fail "sintaxe Bash inválida: ${shell_script#"$ROOT/"}"
    fi
  done < <(find "$ROOT" -maxdepth 1 -type f -name '*.sh' -print0)
}

validate_markdown() {
  local document="$1" output

  if ! output="$(awk '
    BEGIN { fenced = 0; h1 = 0; previous = 0; expect_blank = 0; errors = 0 }
    /^```|^~~~/ { fenced = !fenced; next }
    fenced { next }
    {
      if (expect_blank && NF > 0) {
        print "linha " NR ": falta linha em branco após o título anterior"
        errors++
      }
      expect_blank = 0

      if ($0 ~ /^#{1,6} /) {
        level = match($0, /[^#]/) - 1
        if (level == 1) h1++
        if (previous && level > previous + 1) {
          print "linha " NR ": salto de nível de título"
          errors++
        }
        previous = level
        expect_blank = 1
      }

      if ($0 ~ /[[:blank:]]+$/) {
        print "linha " NR ": espaço em branco no fim da linha"
        errors++
      }
    }
    END {
      if (fenced) {
        print "bloco de código não fechado"
        errors++
      }
      if (h1 != 1) {
        print "esperado exatamente um H1; encontrado: " h1
        errors++
      }
      exit errors > 0
    }
  ' "$document")"; then
    fail "Markdown inválido em ${document#"$ROOT/"}: ${output//$'\n'/; }"
  fi
}

validate_markdown_files() {
  local document

  while IFS= read -r -d '' document; do
    validate_markdown "$document"
  done < <(find "$ROOT" -type f -name '*.md' -print0)
}

validate_skill_reference_links() {
  local skill_dir="$1" skill_file="$2" relative_link

  while IFS= read -r relative_link; do
    [ -n "$relative_link" ] || continue
    if [ ! -e "$skill_dir/$relative_link" ]; then
      fail "referência ausente em ${skill_file#"$ROOT/"}: $relative_link"
    fi
  done < <(grep -oE '\]\(references/[^)#[:space:]]+' "$skill_file" | sed 's/^](//' || true)
}

validate_skills() {
  local skill_dir skill_name skill_file metadata_file declared_name frontmatter_end
  local skill_count=0

  shopt -s nullglob
  for skill_dir in "$ROOT"/skills/*/; do
    skill_count=$((skill_count + 1))
    skill_name="$(basename "$skill_dir")"
    skill_file="${skill_dir}SKILL.md"
    metadata_file="${skill_dir}agents/openai.yaml"

    if [[ ! "$skill_name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
      fail "nome de diretório de skill inválido: $skill_name"
    fi

    if [ ! -f "$skill_file" ]; then
      fail "SKILL.md ausente em skills/$skill_name"
      continue
    fi

    if [ "$(sed -n '1p' "$skill_file")" != "---" ]; then
      fail "frontmatter inicial ausente em skills/$skill_name/SKILL.md"
    fi

    frontmatter_end="$(awk 'NR > 1 && $0 == "---" { print NR; exit }' "$skill_file")"
    if [ -z "$frontmatter_end" ]; then
      fail "frontmatter não fechado em skills/$skill_name/SKILL.md"
    fi

    declared_name="$(awk -F ': *' 'NR > 1 && $0 == "---" { exit } $1 == "name" { value=$2; gsub(/^"|"$/, "", value); print value; exit }' "$skill_file")"
    if [ "$declared_name" != "$skill_name" ]; then
      fail "name da skill '$declared_name' não corresponde ao diretório '$skill_name'"
    fi

    if ! awk -F ': *' 'NR > 1 && $0 == "---" { exit !found } $1 == "description" && length($2) > 2 { found=1 } END { exit !found }' "$skill_file"; then
      fail "description ausente no frontmatter de skills/$skill_name/SKILL.md"
    fi

    if [ ! -f "$metadata_file" ]; then
      fail "agents/openai.yaml ausente em skills/$skill_name"
    else
      for metadata_key in display_name short_description default_prompt; do
        if ! grep -Eq "^[[:space:]]{2}${metadata_key}:" "$metadata_file"; then
          fail "$metadata_key ausente em skills/$skill_name/agents/openai.yaml"
        fi
      done

      if ! grep -E '^  default_prompt:' "$metadata_file" | grep -Fq "\$$skill_name"; then
        fail "default_prompt não referencia \$$skill_name em skills/$skill_name/agents/openai.yaml"
      fi
    fi

    validate_skill_reference_links "$skill_dir" "$skill_file"
  done

  if [ "$skill_count" -eq 0 ]; then
    fail "nenhuma skill encontrada em skills/"
  fi
}

validate_required_paths
validate_publication_safety
validate_shell_scripts
validate_markdown_files
validate_skills

if [ "$CHECK_INSTALLED" = true ]; then
  if ! "$ROOT/setup.sh" --check; then
    fail "instalação global inválida"
  fi
fi

if [ "$failures" -gt 0 ]; then
  echo "Falha: $failures problema(s) encontrado(s)." >&2
  exit 1
fi

echo "Validação concluída: estrutura, Markdown, skills e segurança de publicação estão corretos."
