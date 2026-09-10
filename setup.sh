#!/usr/bin/env bash
# Links this repository to the global Claude Code and Codex CLI configuration.
# The operation is idempotent, preserves existing JSON settings, and never
# removes conflicting real files or orphaned links automatically.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODE="apply"
failures=0

usage() {
  echo "Uso: $0 [--check]"
  echo "  --check  Verifica os links sem alterar o sistema de arquivos."
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

if [ "$#" -gt 1 ]; then
  usage >&2
  exit 2
fi

report_error() {
  echo "ERRO: $1" >&2
  failures=$((failures + 1))
}

link() {
  local src="$1" dest="$2" current_target

  if [ ! -e "$src" ]; then
    report_error "origem inexistente: $src"
    return
  fi

  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    report_error "$dest já existe e não é um symlink; resolva o conflito manualmente."
    return
  fi

  if [ "$MODE" = "check" ]; then
    if [ ! -L "$dest" ]; then
      report_error "link ausente: $dest -> $src"
      return
    fi

    current_target="$(readlink "$dest")"
    if [ "$current_target" != "$src" ]; then
      report_error "$dest aponta para $current_target; esperado: $src"
      return
    fi

    if [ ! -e "$dest" ]; then
      report_error "link quebrado: $dest -> $src"
      return
    fi

    echo "OK: $dest -> $src"
    return
  fi

  mkdir -p "$(dirname "$dest")"
  ln -sfn "$src" "$dest"
  echo "OK: $dest -> $src"
}

check_orphaned_skill_links() {
  local skills_dir="$1" dest current_target

  [ -d "$skills_dir" ] || return

  for dest in "$skills_dir"/*; do
    [ -L "$dest" ] || continue
    current_target="$(readlink "$dest")"

    case "$current_target" in
      "$ROOT/skills/"*|"$ROOT/claude/skills/"*)
        if [ ! -e "$dest" ]; then
          report_error "link de skill órfão: $dest -> $current_target; remova-o manualmente."
        fi
        ;;
    esac
  done
}

link "$ROOT/AGENTS.md" "$HOME/.codex/AGENTS.md"
link "$ROOT/AGENTS.md" "$HOME/.claude/CLAUDE.md"
link "$ROOT/rules" "$HOME/.claude/rules"
link "$ROOT/skills" "$HOME/.claude/skills"
link "$ROOT/claude/agents" "$HOME/.claude/agents"
link "$ROOT/claude/commands" "$HOME/.claude/commands"
link "$ROOT/hooks/stage-gate.sh" "$HOME/.claude/hooks/ai-config-stage-gate.sh"
link "$ROOT/hooks/stage-gate.sh" "$HOME/.codex/hooks/ai-config-stage-gate.sh"

if [ "$(readlink "$HOME/.claude/hooks/ai-config-stage-gate.sh" 2>/dev/null)" != "$ROOT/hooks/stage-gate.sh" ] ||
   [ "$(readlink "$HOME/.codex/hooks/ai-config-stage-gate.sh" 2>/dev/null)" != "$ROOT/hooks/stage-gate.sh" ]; then
  report_error "os hooks não foram configurados porque seus links estão inválidos."
elif [ "$MODE" = "check" ]; then
  "$ROOT/scripts/configure-hooks.sh" --check || report_error "configuração de hooks inválida."
else
  "$ROOT/scripts/configure-hooks.sh" || report_error "não foi possível configurar os hooks."
fi

# Link shared skills individually to preserve unrelated skills in each agent's
# personal directory.
shopt -s nullglob
for skill_dir in "$ROOT"/skills/*/; do
  skill_name="$(basename "$skill_dir")"
  link "${skill_dir%/}" "$HOME/.agents/skills/$skill_name"

  # Compatibility with Codex installations that still use the legacy path.
  link "${skill_dir%/}" "$HOME/.codex/skills/$skill_name"
done

check_orphaned_skill_links "$HOME/.agents/skills"
check_orphaned_skill_links "$HOME/.codex/skills"

if [ "$failures" -gt 0 ]; then
  echo "Falha: $failures problema(s) encontrado(s)." >&2
  exit 1
fi

if [ "$MODE" = "check" ]; then
  echo "Verificação concluída: todos os links estão corretos."
fi
