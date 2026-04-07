#!/usr/bin/env bash
# sync_repos.sh — sync one or all git repos to remote
# Usage:
#   sync_repos.sh                  # sync all repos
#   sync_repos.sh <repo-name>      # sync one repo by exact name
#   sync_repos.sh --fuzzy <keyword> # fuzzy-match repos by keyword

REPOS_ROOT="$HOME/Documents/gitlocal"
TODAY=$(date '+%Y-%m-%d')

SUCCESS=()
SKIPPED=()
FAILED=()
FAILED_MSGS=()

sync_one() {
  local repo_path="$1"
  local repo_name
  repo_name=$(basename "$repo_path")

  echo ""
  echo "▶ Syncing: $repo_name"

  # git pull
  pull_out=$(cd "$repo_path" && git pull 2>&1)
  if [ $? -ne 0 ]; then
    echo "  ✗ git pull failed"
    FAILED+=("$repo_name")
    FAILED_MSGS+=("[$repo_name] git pull: $pull_out")
    return
  fi
  echo "  pull: ok"

  # git add .
  add_out=$(cd "$repo_path" && git add . 2>&1)
  if [ $? -ne 0 ]; then
    echo "  ✗ git add failed"
    FAILED+=("$repo_name")
    FAILED_MSGS+=("[$repo_name] git add: $add_out")
    return
  fi

  # check if anything is staged
  cd "$repo_path" && git diff --cached --quiet
  if [ $? -eq 0 ]; then
    echo "  skip commit: nothing to commit"
    # still push (in case of previous un-pushed commits)
    push_out=$(cd "$repo_path" && git push 2>&1)
    if [ $? -ne 0 ]; then
      echo "  ✗ git push failed"
      FAILED+=("$repo_name")
      FAILED_MSGS+=("[$repo_name] git push: $push_out")
    else
      echo "  push: ok"
      SKIPPED+=("$repo_name")
    fi
    return
  fi

  # git commit
  commit_out=$(cd "$repo_path" && git commit -m "$TODAY" 2>&1)
  if [ $? -ne 0 ]; then
    echo "  ✗ git commit failed"
    FAILED+=("$repo_name")
    FAILED_MSGS+=("[$repo_name] git commit: $commit_out")
    return
  fi
  echo "  commit: $TODAY"

  # git push
  push_out=$(cd "$repo_path" && git push 2>&1)
  if [ $? -ne 0 ]; then
    echo "  ✗ git push failed"
    FAILED+=("$repo_name")
    FAILED_MSGS+=("[$repo_name] git push: $push_out")
    return
  fi
  echo "  push: ok"
  SUCCESS+=("$repo_name")
}

find_repos_fuzzy() {
  local keyword="$1"
  for d in "$REPOS_ROOT"/*/; do
    [ -d "$d/.git" ] && basename "$d"
  done | grep -i "$keyword"
}

find_all_repos() {
  for d in "$REPOS_ROOT"/*/; do
    [ -d "$d/.git" ] && echo "$d"
  done
}

# ── Main ───────────────────────────────────────────────────────────────────

if [ ! -d "$REPOS_ROOT" ]; then
  echo "ERROR: Repos root not found: $REPOS_ROOT"
  exit 1
fi

echo "=== Git Sync — $TODAY ==="

if [ "$1" = "--fuzzy" ]; then
  # fuzzy match mode
  keyword="$2"
  matches=$(find_repos_fuzzy "$keyword")
  count=$(echo "$matches" | grep -c .)
  if [ -z "$matches" ]; then
    echo "No repos matched keyword: $keyword"
    echo "Available repos:"
    find_all_repos | xargs -I{} basename {}
    exit 1
  elif [ "$count" -gt 1 ]; then
    echo "Multiple repos matched '$keyword':"
    echo "$matches"
    echo ""
    echo "Please re-run with an exact name: sync_repos.sh <repo-name>"
    exit 1
  else
    repo_name=$(echo "$matches" | tr -d '[:space:]')
    sync_one "$REPOS_ROOT/$repo_name"
  fi

elif [ -n "$1" ]; then
  # exact name mode
  target="$REPOS_ROOT/$1"
  if [ ! -d "$target/.git" ]; then
    echo "Repo not found: $1"
    echo "Available repos:"
    find_all_repos | xargs -I{} basename {}
    exit 1
  fi
  sync_one "$target"

else
  # sync all
  while IFS= read -r repo_path; do
    sync_one "$repo_path"
  done < <(find_all_repos)
fi

# ── Report ─────────────────────────────────────────────────────────────────

echo ""
echo "══════════════════════════════════"
echo "Sync Report — $TODAY"
echo "══════════════════════════════════"

if [ ${#SUCCESS[@]} -gt 0 ]; then
  echo ""
  echo "✓ Synced successfully:"
  for r in "${SUCCESS[@]}"; do echo "  - $r"; done
fi

if [ ${#SKIPPED[@]} -gt 0 ]; then
  echo ""
  echo "○ Already up to date (nothing to commit):"
  for r in "${SKIPPED[@]}"; do echo "  - $r"; done
fi

if [ ${#FAILED[@]} -gt 0 ]; then
  echo ""
  echo "✗ Failed — needs your attention:"
  for msg in "${FAILED_MSGS[@]}"; do
    echo ""
    echo "  $msg"
  done
fi

echo ""
