#!/usr/bin/env bash
# Typora 使用时的笔记库自动同步：有改动则 commit，然后始终 pull --rebase 并 push
set -euo pipefail

export PATH="/opt/homebrew/bin:/usr/bin:/bin"
VAULT="/Users/morrow/ObsidianNotes/MyLittleHouse"
LOG="$VAULT/.scripts/backup.log"
mkdir -p "$VAULT/.scripts"
cd "$VAULT"

{
  echo "----- $(date '+%Y-%m-%d %H:%M:%S') -----"

  git add -A
  if git diff --cached --quiet; then
    echo "no local changes"
  else
    git commit -m "vault backup: $(date '+%Y-%m-%d %H:%M:%S')"
  fi

  git pull --rebase origin master
  git push origin master
  echo "ok"
} >>"$LOG" 2>&1
