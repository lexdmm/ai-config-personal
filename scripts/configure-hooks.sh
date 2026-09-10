#!/usr/bin/env bash
# Merges the required hooks while preserving unrelated agent settings.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODE="apply"
failures=0

usage() {
  echo "Uso: $0 [--check]"
  echo "  --check  Verifica os hooks sem alterar as configurações."
}

fail() {
  echo "ERRO: $1" >&2
  failures=$((failures + 1))
}

case "${1:-}" in
  "") ;;
  --check) MODE="check" ;;
  -h|--help)
    usage
    exit 0
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac

[ "$#" -le 1 ] || { usage >&2; exit 2; }
command -v jq >/dev/null 2>&1 || {
  fail "jq é obrigatório para configurar os hooks."
  exit 1
}

contains_required_hooks() {
  local required_file="$1" settings_file="$2"

  jq -e --slurpfile required "$required_file" '
    . as $actual |
    all($required[0].hooks | to_entries[];
      . as $event |
      all($event.value[];
        . as $group |
        any(($actual.hooks[$event.key] // [])[]; . == $group)
      )
    )
  ' "$settings_file" >/dev/null 2>&1
}

merge_hooks() {
  local required_file="$1" settings_file="$2" temp_file settings_dir

  if ! jq -e '.hooks | type == "object"' "$required_file" >/dev/null 2>&1; then
    fail "definição de hooks inválida: $required_file"
    return
  fi

  if [ "$MODE" = "check" ]; then
    if [ ! -f "$settings_file" ] || ! contains_required_hooks "$required_file" "$settings_file"; then
      fail "hooks obrigatórios ausentes ou configuração inválida: $settings_file"
      return
    fi
    echo "OK: hooks configurados em $settings_file"
    return
  fi

  if [ -L "$settings_file" ]; then
    fail "$settings_file é um symlink; atualize o destino explicitamente."
    return
  fi
  if [ -e "$settings_file" ] && [ ! -f "$settings_file" ]; then
    fail "$settings_file existe e não é um arquivo regular."
    return
  fi

  settings_dir="$(dirname "$settings_file")"
  mkdir -p "$settings_dir" || {
    fail "não foi possível criar $settings_dir."
    return
  }
  temp_file="$(mktemp "$settings_dir/.ai-config-hooks.XXXXXX")" || {
    fail "não foi possível preparar a atualização de $settings_file."
    return
  }

  if [ -f "$settings_file" ]; then
    if ! jq --slurpfile required "$required_file" '
      def add_required($config):
        reduce ($config.hooks | to_entries[]) as $event
          (. | .hooks = (.hooks // {});
            reduce $event.value[] as $group
              (.;
                if any((.hooks[$event.key] // [])[]; . == $group)
                then .
                else .hooks[$event.key] = ((.hooks[$event.key] // []) + [$group])
                end
              )
          );
      add_required($required[0])
    ' "$settings_file" > "$temp_file"; then
      rm -f -- "$temp_file"
      fail "não foi possível preservar e atualizar $settings_file."
      return
    fi
    chmod --reference="$settings_file" "$temp_file"
  elif ! printf '{}\n' | jq --slurpfile required "$required_file" '
    .hooks = $required[0].hooks
  ' > "$temp_file"; then
    rm -f -- "$temp_file"
    fail "não foi possível criar $settings_file."
    return
  fi

  if ! mv -- "$temp_file" "$settings_file"; then
    rm -f -- "$temp_file"
    fail "não foi possível instalar os hooks em $settings_file."
    return
  fi
  echo "OK: hooks configurados em $settings_file"
}

merge_hooks "$ROOT/hooks/claude.json" "$HOME/.claude/settings.json"
merge_hooks "$ROOT/hooks/codex.json" "$HOME/.codex/hooks.json"

if [ "$failures" -gt 0 ]; then
  echo "Falha: $failures problema(s) encontrado(s)." >&2
  exit 1
fi

if [ "$MODE" = "check" ]; then
  echo "Verificação concluída: os hooks obrigatórios estão configurados."
fi
