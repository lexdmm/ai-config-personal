#!/usr/bin/env bash
# Blocks turn completion when repository changes were not verified after the turn began.
set -uo pipefail

command -v jq >/dev/null 2>&1 || exit 0
command -v sha256sum >/dev/null 2>&1 || exit 0

SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")" || exit 0
CONFIG_ROOT="$(cd "$(dirname "$SCRIPT_PATH")/.." && pwd)" || exit 0
VERIFIER="$CONFIG_ROOT/scripts/verify-stage.sh"
[ -x "$VERIFIER" ] || exit 0

HOOK_DATA="$(jq -r '
  [
    (.hook_event_name // ""),
    (.session_id // "unknown"),
    (.turn_id // .prompt_id // "current"),
    (.cwd // "")
  ] | @tsv
' 2>/dev/null)" || exit 0
IFS=$'\t' read -r HOOK_EVENT SESSION_ID TURN_ID HOOK_CWD <<< "$HOOK_DATA"

[ -n "$HOOK_CWD" ] && [ -d "$HOOK_CWD" ] || exit 0
case "$HOOK_EVENT" in
  UserPromptSubmit|Stop) ;;
  *) exit 0 ;;
esac

umask 077
PREFERRED_STATE_ROOT="${XDG_RUNTIME_DIR:-/tmp}/ai-config-stage-gate"
STATE_PROBE="$PREFERRED_STATE_ROOT/.write-test-$$"
if mkdir -p -- "$PREFERRED_STATE_ROOT" 2>/dev/null &&
   { : > "$STATE_PROBE"; } 2>/dev/null; then
  rm -f -- "$STATE_PROBE"
  STATE_ROOT="$PREFERRED_STATE_ROOT"
else
  STATE_ROOT="/tmp/ai-config-stage-gate-$UID"
  [ ! -L "$STATE_ROOT" ] || exit 0
  mkdir -p -- "$STATE_ROOT" 2>/dev/null || exit 0
fi

STATE_KEY="$(printf '%s\0%s\0%s' "$SESSION_ID" "$TURN_ID" "$HOOK_CWD" |
  sha256sum | awk '{print $1}')"
TURN_STATE="$STATE_ROOT/$STATE_KEY.state"

fingerprint() {
  (cd -- "$HOOK_CWD" && "$VERIFIER" --fingerprint 2>/dev/null)
}

if [ "$HOOK_EVENT" = "UserPromptSubmit" ]; then
  INITIAL_FINGERPRINT="$(fingerprint)" || exit 0
  if [ ! -e "$TURN_STATE" ]; then
    (
      set -C
      printf '%s\n' "$INITIAL_FINGERPRINT" > "$TURN_STATE"
    ) 2>/dev/null || true
  fi
  exit 0
fi

[ -f "$TURN_STATE" ] || exit 0
read -r INITIAL_FINGERPRINT < "$TURN_STATE" || exit 0
CURRENT_FINGERPRINT="$(fingerprint)" || {
  rm -f -- "$TURN_STATE"
  exit 0
}

if [ "$CURRENT_FINGERPRINT" = "$INITIAL_FINGERPRINT" ]; then
  rm -f -- "$TURN_STATE"
  exit 0
fi

if (
  cd -- "$HOOK_CWD" &&
  AI_CONFIG_VERIFICATION_NOT_BEFORE_FILE="$TURN_STATE" \
    "$VERIFIER" --status >/dev/null 2>&1
); then
  rm -f -- "$TURN_STATE"
  exit 0
fi

REASON="The repository changed during this turn, but the current stage was not verified after those changes. Reopen the applicable AGENTS.md and stack rules, inspect the actual staged, unstaged, and untracked files, run the proportional validations, and fix any violation. Then run '$VERIFIER -- <paths changed in this stage>' or use '--all' only if every pending change belongs to this stage. Do not finish until the verifier passes; keep unrelated user changes untouched and end with the required Suggested commit line."
jq -n --arg reason "$REASON" '{decision: "block", reason: $reason}'
