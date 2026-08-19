#!/usr/bin/env bash
# 笔记库自动同步：有实质改动才 commit，然后 pull --rebase 并 push
# 日志必须留在仓库外，否则每次写入 log 都会被当成新改动再 commit
set -euo pipefail

export PATH="/opt/homebrew/bin:/usr/bin:/bin"
VAULT="/Users/morrow/ObsidianNotes/MyLittleHouse"
LOG="$HOME/Library/Logs/mylittlehouse-backup.log"
mkdir -p "$(dirname "$LOG")"
cd "$VAULT"

{
  echo "----- $(date '+%Y-%m-%d %H:%M:%S') -----"

  git add -A
  if git diff --cached --quiet; then
    echo "no local changes"
  else
    git commit -m "vault backup: $(date '+%Y-%m-%d %H:%M:%S')"
  fi

  git pull --rebase --autostash origin master
  git push origin master
  echo "ok"
} >>"$LOG" 2>&1
