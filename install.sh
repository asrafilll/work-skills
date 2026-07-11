#!/usr/bin/env bash
# install.sh — install skills from this library into Claude Code and/or Codex.
#
# Usage:
#   ./install.sh                          # interactive: pick target + skills
#   ./install.sh --all                    # install every skill (asks target)
#   ./install.sh --all --target both      # everything, everywhere, no prompts
#   ./install.sh pre-flight whats-next --target claude
#   ./install.sh --list                   # show available skills
#
# Targets:
#   claude  -> ~/.claude/skills   (override: CLAUDE_SKILLS_DIR)
#   codex   -> ~/.codex/skills    (override: CODEX_SKILLS_DIR)
#   both    -> both of the above
#
# Skills with a variants/codex/ folder install that variant into Codex;
# everything else installs the top-level skill as-is (variants/ stripped).

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
CODEX_DIR="${CODEX_SKILLS_DIR:-$HOME/.codex/skills}"

# ---------- discover skills (any top-level dir containing SKILL.md) ----------
SKILLS=()
for d in "$REPO_DIR"/*/; do
  [ -f "${d}SKILL.md" ] && SKILLS+=("$(basename "$d")")
done
[ "${#SKILLS[@]}" -gt 0 ] || { echo "No skills found next to install.sh"; exit 1; }

desc_of() { # first sentence of the SKILL.md description (handles folded '>' style)
  awk '
    /^description:/ {
      sub(/^description:[ ]*"?/, "")
      if ($0 ~ /^[>|][-+]?[ ]*$/) { folded = 1; next }
      print; exit
    }
    folded && /^[ ]/ { sub(/^[ ]+/, ""); print; exit }
  ' "$REPO_DIR/$1/SKILL.md" | cut -d'.' -f1 | cut -c1-80
}

list_skills() {
  local i=1 s
  for s in "${SKILLS[@]}"; do
    printf '  %2d) %-20s %s\n' "$i" "$s" "$(desc_of "$s")"
    i=$((i + 1))
  done
}

# ---------- parse args ----------
TARGET=""
FORCE=0
PICK_ALL=0
REQUESTED=()
while [ $# -gt 0 ]; do
  case "$1" in
    --target)  TARGET="${2:-}"; shift 2 ;;
    --all)     PICK_ALL=1; shift ;;
    --force)   FORCE=1; shift ;;
    --list)    list_skills; exit 0 ;;
    -h|--help) sed -n '2,17p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*)        echo "Unknown flag: $1"; exit 1 ;;
    *)         REQUESTED+=("$1"); shift ;;
  esac
done

case "$TARGET" in claude|codex|both|"") ;; *) echo "Invalid --target: $TARGET (use claude|codex|both)"; exit 1 ;; esac

# ---------- resolve skill selection ----------
SELECTED=()
if [ "$PICK_ALL" -eq 1 ]; then
  SELECTED=("${SKILLS[@]}")
elif [ "${#REQUESTED[@]}" -gt 0 ]; then
  for r in "${REQUESTED[@]}"; do
    found=0
    for s in "${SKILLS[@]}"; do [ "$s" = "$r" ] && found=1; done
    [ "$found" -eq 1 ] || { echo "Unknown skill: $r (try --list)"; exit 1; }
    SELECTED+=("$r")
  done
else
  echo "Available skills:"
  list_skills
  echo
  printf 'Install which? ("all", or numbers/names space-separated): '
  read -r answer
  if [ "$answer" = "all" ] || [ "$answer" = "a" ]; then
    SELECTED=("${SKILLS[@]}")
  else
    for token in $answer; do
      if printf '%s' "$token" | grep -q '^[0-9]\+$'; then
        idx=$((token - 1))
        [ "$idx" -ge 0 ] && [ "$idx" -lt "${#SKILLS[@]}" ] || { echo "Bad number: $token"; exit 1; }
        SELECTED+=("${SKILLS[$idx]}")
      else
        found=0
        for s in "${SKILLS[@]}"; do [ "$s" = "$token" ] && found=1; done
        [ "$found" -eq 1 ] || { echo "Unknown skill: $token"; exit 1; }
        SELECTED+=("$token")
      fi
    done
  fi
fi
[ "${#SELECTED[@]}" -gt 0 ] || { echo "Nothing selected."; exit 0; }

# ---------- resolve target ----------
if [ -z "$TARGET" ]; then
  printf 'Install into which agent? [claude/codex/both] (default: claude): '
  read -r TARGET
  TARGET="${TARGET:-claude}"
  case "$TARGET" in claude|codex|both) ;; *) echo "Invalid target: $TARGET"; exit 1 ;; esac
fi

# ---------- install ----------
install_one() { # $1=skill $2=dest_root $3=flavor(claude|codex)
  local skill="$1" dest_root="$2" flavor="$3"
  local src="$REPO_DIR/$skill" dest="$dest_root/$skill"

  if [ "$flavor" = "codex" ] && [ -d "$src/variants/codex" ]; then
    src="$src/variants/codex"
  fi

  if [ -e "$dest" ] && [ "$FORCE" -ne 1 ]; then
    printf '  %-20s exists in %s — overwrite? [y/N] ' "$skill" "$dest_root"
    read -r yn
    case "$yn" in y|Y) ;; *) echo "  skipped $skill"; return 0 ;; esac
  fi

  rm -rf "$dest"
  mkdir -p "$dest"
  cp -R "$src/." "$dest/"
  rm -rf "$dest/variants"
  echo "  installed $skill -> $dest"
}

for flavor in claude codex; do
  case "$TARGET" in
    both) ;;
    "$flavor") ;;
    *) continue ;;
  esac
  dest_root="$CLAUDE_DIR"; [ "$flavor" = "codex" ] && dest_root="$CODEX_DIR"
  echo
  echo "Installing to $flavor ($dest_root):"
  mkdir -p "$dest_root"
  for skill in "${SELECTED[@]}"; do
    install_one "$skill" "$dest_root" "$flavor"
  done
done

echo
echo "Done. Restart your agent session so it picks up new skills."
