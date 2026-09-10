#!/usr/bin/env bash
# Performs deterministic checks for the current development stage.
set -uo pipefail

usage() {
  cat <<'EOF'
Uso:
  verify-stage.sh --all
  verify-stage.sh -- caminho/arquivo [outro/caminho ...]
  verify-stage.sh --status

Opções:
  --all     Verifica todos os arquivos alterados no repositório atual.
  --status  Confirma que o estado atual ainda corresponde à última verificação.
EOF
}

die() {
  echo "ERRO: $1" >&2
  exit 1
}

command -v git >/dev/null 2>&1 || die "Git não está disponível."
command -v sha256sum >/dev/null 2>&1 || die "sha256sum não está disponível."

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" ||
  die "execute o verificador dentro de um repositório Git."
git -C "$REPO_ROOT" rev-parse --verify HEAD >/dev/null 2>&1 ||
  die "o repositório precisa ter um commit inicial."

umask 077
PREFERRED_STATE_ROOT="${XDG_RUNTIME_DIR:-/tmp}/ai-config-stage-verification"
STATE_PROBE="$PREFERRED_STATE_ROOT/.write-test-$$"
if mkdir -p -- "$PREFERRED_STATE_ROOT" 2>/dev/null &&
   { : > "$STATE_PROBE"; } 2>/dev/null; then
  rm -f -- "$STATE_PROBE"
  STATE_ROOT="$PREFERRED_STATE_ROOT"
else
  STATE_ROOT="/tmp/ai-config-stage-verification-$UID"
  mkdir -p -- "$STATE_ROOT" || die "não foi possível criar o diretório de comprovantes."
fi
RECEIPT_CONTEXT="${AI_CONFIG_VERIFICATION_CONTEXT:-default}"
RECEIPT_KEY="$(printf '%s\0%s' "$REPO_ROOT" "$RECEIPT_CONTEXT" | sha256sum | awk '{print $1}')"
RECEIPT_FILE="$STATE_ROOT/$RECEIPT_KEY.receipt"

TEMP_DIR="$(mktemp -d)" || die "não foi possível criar o diretório temporário."
trap 'rm -rf -- "$TEMP_DIR"' EXIT

calculate_fingerprint() {
  local state_file="$TEMP_DIR/repository-state" file

  : > "$state_file"
  git -C "$REPO_ROOT" rev-parse HEAD >> "$state_file" || return 1
  git -C "$REPO_ROOT" status --porcelain=v2 -z >> "$state_file" || return 1
  git -C "$REPO_ROOT" diff --binary --no-ext-diff HEAD -- >> "$state_file" || return 1
  git -C "$REPO_ROOT" diff --cached --binary --no-ext-diff HEAD -- >> "$state_file" || return 1

  while IFS= read -r -d '' file; do
    printf '%s\0' "$file" >> "$state_file"
    stat -c 'mode:%a type:%F' -- "$REPO_ROOT/$file" >> "$state_file" || return 1
    if [ -L "$REPO_ROOT/$file" ]; then
      printf 'symlink:%s\0' "$(readlink -- "$REPO_ROOT/$file")" >> "$state_file"
    elif [ -f "$REPO_ROOT/$file" ]; then
      sha256sum -- "$REPO_ROOT/$file" >> "$state_file" || return 1
    else
      printf 'special\0' >> "$state_file"
    fi
  done < <(git -C "$REPO_ROOT" ls-files --others --exclude-standard -z)

  sha256sum "$state_file" | awk '{print $1}'
}

if [ "${1:-}" = "--fingerprint" ]; then
  [ "$#" -eq 1 ] || { usage >&2; exit 2; }
  calculate_fingerprint || die "não foi possível calcular o estado atual."
  exit 0
fi

if [ "${1:-}" = "--status" ]; then
  [ "$#" -eq 1 ] || { usage >&2; exit 2; }
  [ -f "$RECEIPT_FILE" ] || die "nenhuma verificação anterior foi registrada para este projeto."
  if [ -n "${AI_CONFIG_VERIFICATION_NOT_BEFORE_FILE:-}" ]; then
    [ -e "$AI_CONFIG_VERIFICATION_NOT_BEFORE_FILE" ] ||
      die "a referência de início da etapa não existe."
    [ "$RECEIPT_FILE" -nt "$AI_CONFIG_VERIFICATION_NOT_BEFORE_FILE" ] ||
      die "a verificação registrada é anterior às alterações desta etapa."
  fi
  CURRENT_FINGERPRINT="$(calculate_fingerprint)" || die "não foi possível calcular o estado atual."
  read -r SAVED_FINGERPRINT < "$RECEIPT_FILE" || die "o comprovante de verificação é inválido."
  [ "$CURRENT_FINGERPRINT" = "$SAVED_FINGERPRINT" ] ||
    die "o projeto mudou desde a última verificação; execute o verificador novamente."
  echo "Verificação da etapa ainda válida."
  exit 0
fi

VERIFY_ALL=false
case "${1:-}" in
  --all)
    [ "$#" -eq 1 ] || { usage >&2; exit 2; }
    VERIFY_ALL=true
    ;;
  --)
    shift
    [ "$#" -gt 0 ] || { usage >&2; exit 2; }
    ;;
  -h|--help)
    usage
    exit 0
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac

declare -A CHANGED_SET=()
declare -A UNTRACKED_SET=()
declare -a CHANGED_FILES=()
while IFS= read -r -d '' file; do
  if [ -z "${CHANGED_SET[$file]+present}" ]; then
    CHANGED_SET["$file"]=1
    CHANGED_FILES+=("$file")
  fi
done < <(
  git -C "$REPO_ROOT" diff --name-only -z
  git -C "$REPO_ROOT" diff --cached --name-only -z
  git -C "$REPO_ROOT" ls-files --others --exclude-standard -z
)
while IFS= read -r -d '' file; do
  UNTRACKED_SET["$file"]=1
done < <(git -C "$REPO_ROOT" ls-files --others --exclude-standard -z)

[ "${#CHANGED_FILES[@]}" -gt 0 ] || die "nenhum arquivo alterado foi encontrado."

declare -a SCOPED_FILES=()
if [ "$VERIFY_ALL" = true ]; then
  SCOPED_FILES=("${CHANGED_FILES[@]}")
else
  declare -A SCOPED_SET=()
  for scope in "$@"; do
    scope="${scope#./}"
    scope="${scope%/}"
    case "$scope" in
      ''|/*|..|../*|*/../*|*/..)
        die "escopo inválido: $scope"
        ;;
    esac

    matched=false
    for file in "${CHANGED_FILES[@]}"; do
      if [ "$scope" = "." ] || [ "$file" = "$scope" ] || [[ "$file" == "$scope/"* ]]; then
        matched=true
        if [ -z "${SCOPED_SET[$file]+present}" ]; then
          SCOPED_SET["$file"]=1
          SCOPED_FILES+=("$file")
        fi
      fi
    done
    [ "$matched" = true ] || die "o escopo não contém arquivos alterados: $scope"
  done
fi

SECRET_PATTERN='(BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY|AKIA[0-9A-Z]{16}|gh[pousr]_[A-Za-z0-9_]{20,}|github_pat_[A-Za-z0-9_]{20,}|sk-[A-Za-z0-9_-]{20,}|xox[baprs]-[A-Za-z0-9-]{10,}|(password|passwd|api[_-]?key|secret|token)[[:space:]]*[:=][[:space:]]*["'"'][^"'"']{8,}["'"'])'
CONFLICT_PATTERN='^(<<<<<<< .+|=======|>>>>>>> .+)$'
declare -A REPORTED=()
failures=0

report_issue() {
  local kind="$1" message="$2" path="$3" key="$kind:$path"
  if [ -z "${REPORTED[$key]+present}" ]; then
    REPORTED["$key"]=1
    echo "ERRO: $message: $path" >&2
    failures=$((failures + 1))
  fi
}

scan_added_content() {
  local path="$1" content_file="$2"
  [ -s "$content_file" ] || return 0

  if grep -Eq "$CONFLICT_PATTERN" "$content_file"; then
    report_issue conflict "marcador de conflito não resolvido" "$path"
  fi
  if grep -Eiq "$SECRET_PATTERN" "$content_file"; then
    report_issue secret "possível segredo adicionado" "$path"
  fi

  case "$path" in
    *.php)
      if grep -Eq '(^|[^[:alnum:]_])(dd|dump|var_dump|ray)[[:space:]]*\(' "$content_file"; then
        report_issue debug "comando comum de debug adicionado" "$path"
      fi
      ;;
    *.js|*.jsx|*.ts|*.tsx|*.mjs|*.cjs)
      if grep -Eq '(^|[^[:alnum:]_])console\.log[[:space:]]*\(' "$content_file"; then
        report_issue debug "comando comum de debug adicionado" "$path"
      fi
      ;;
  esac
}

extract_added_lines() {
  awk '/^\+\+\+ / { next } /^\+/ { sub(/^\+/, ""); print }'
}

for file in "${SCOPED_FILES[@]}"; do
  staged_file="$TEMP_DIR/staged-$failures"
  unstaged_file="$TEMP_DIR/unstaged-$failures"

  if ! git -C "$REPO_ROOT" diff --cached --check -- "$file" >/dev/null 2>&1; then
    report_issue whitespace "espaço em branco inválido nas alterações staged" "$file"
  fi
  if ! git -C "$REPO_ROOT" diff --check -- "$file" >/dev/null 2>&1; then
    report_issue whitespace "espaço em branco inválido nas alterações unstaged" "$file"
  fi

  if ! git -C "$REPO_ROOT" diff --cached --unified=0 --no-ext-diff -- "$file" |
       extract_added_lines > "$staged_file"; then
    die "não foi possível inspecionar as alterações staged."
  fi
  if ! git -C "$REPO_ROOT" diff --unified=0 --no-ext-diff -- "$file" |
       extract_added_lines > "$unstaged_file"; then
    die "não foi possível inspecionar as alterações unstaged."
  fi
  scan_added_content "$file" "$staged_file"
  scan_added_content "$file" "$unstaged_file"

  if [ -n "${UNTRACKED_SET[$file]+present}" ] &&
     [ -f "$REPO_ROOT/$file" ] && [ ! -L "$REPO_ROOT/$file" ]; then
    if LC_ALL=C grep -Iq '' "$REPO_ROOT/$file" || [ ! -s "$REPO_ROOT/$file" ]; then
      if awk '/[[:blank:]]+$/ { found=1; exit } END { exit !found }' "$REPO_ROOT/$file"; then
        report_issue whitespace "espaço em branco inválido em arquivo novo" "$file"
      fi
      scan_added_content "$file" "$REPO_ROOT/$file"
    fi
  fi
done

[ "$failures" -eq 0 ] || die "$failures problema(s) mecânico(s) encontrado(s)."

FINGERPRINT="$(calculate_fingerprint)" || die "não foi possível calcular o estado verificado."
{
  printf '%s\n' "$FINGERPRINT"
  printf 'verified_files=%s\n' "${#SCOPED_FILES[@]}"
  printf 'verified_at=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
} > "$RECEIPT_FILE" || die "não foi possível registrar o comprovante."

echo "Verificação mecânica concluída para ${#SCOPED_FILES[@]} arquivo(s)."
