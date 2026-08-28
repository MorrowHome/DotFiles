#!/usr/bin/env bash
# Windows 版笔记库自动同步（对应 launchd / vault-backup.sh）
# 有实质改动才 commit，然后 pull --rebase 并 push
# 日志在仓库内但已被 .gitignore，避免每次写 log 再被 commit
set -euo pipefail

export PATH="/usr/bin:/bin:/mingw64/bin:$PATH"
VAULT="/e/ObsidianNotes/MyLittleHouse"
LOG="$VAULT/mylittlehouse-backup.log"

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
