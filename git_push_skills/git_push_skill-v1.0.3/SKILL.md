---
name: git-sync
description: >
  Use this skill to sync, push, pull, or upload local git repositories to remote (GitHub/remote).
  MUST trigger when user says any of: "帮我同步", "同步一下", "上传代码", "push一下", "push代码",
  "sync", "同步仓库", "上传到github", "push to github", "pull一下", "更新远程", "upload code",
  "push changes", "sync repos", "sync all", or any sentence containing push/pull/sync/upload
  combined with code/repo/仓库/代码/github. If user names a specific repo, sync only that one.
  If user says "all" or names no repo, sync every repo under ~/Documents/gitlocal.
---

# git-sync

> **CRITICAL — YOUR VERY FIRST ACTION MUST BE THIS BASH COMMAND. NO EXCEPTIONS.**
>
> Before writing any reply, call the Bash tool immediately with:
> ```bash
> ls ~/Documents/gitlocal/
> ```
> This will show you the actual repos on disk. You MUST do this first.
> Do NOT say "I cannot find the directory". Do NOT ask the user for a path.
> Do NOT say "该目录无法访问". The Bash tool works. Just run it.

This skill runs four git commands (`pull → add → commit → push`) on one or all local repositories under `~/Documents/gitlocal`.

---

## Step 1 — Identify target repos

You already ran `ls ~/Documents/gitlocal/` above. Now get only the git repos:
```bash
for d in ~/Documents/gitlocal/*/; do [ -d "$d/.git" ] && basename "$d"; done
```

Then apply one of the three cases below:

---

### Case A — Exact repo name given
User says something like "sync skills-by-zj" or "push weekly_repo_skill_inGOODLAB".

- Match the name case-insensitively against the repo list.
- If found → proceed to Step 2 with that single repo.
- If not found → fall through to Case B (fuzzy match).

---

### Case B — Keyword / fuzzy match
User says something like "帮我同步有关skill的仓库", "sync the repo about push", "同步跟weekly有关的".

Extract the keyword from the user's message, then run:
```bash
for d in ~/Documents/gitlocal/*/; do
  [ -d "$d/.git" ] && basename "$d"
done | grep -i "<KEYWORD>"
```

**Interpret results:**
- **1 match** → proceed to Step 2. Tell the user: "Matched: `<repo-name>`".
- **2+ matches** → list them and ask: "找到多个匹配的仓库，请确认要同步哪个：\n- repo-a\n- repo-b". Wait for confirmation.
- **0 matches** → tell the user, list all available repos, and stop.

---

### Case C — Sync all
User says "all", "全部", "所有仓库", or gives no repo name.

Use the full repo list. Proceed to Step 2 for every repo.

---

## Step 2 — Sync each repo

For each target repo, run (replace `<REPO_NAME>` with the actual folder name):

```bash
cd ~/Documents/gitlocal/<REPO_NAME> && \
git pull 2>&1 && \
git add . 2>&1 && \
{ git diff --cached --quiet && echo "SKIP_COMMIT_nothing_to_commit"; } || git commit -m "$(date '+%Y-%m-%d')" 2>&1 && \
git push 2>&1
```

**Notes:**
- `git diff --cached --quiet` → exits 0 if nothing staged → prints `SKIP_COMMIT_nothing_to_commit` → skips to push.
- If something is staged → runs `git commit -m "YYYY-MM-DD"` → then push.
- This guarantees `git push` runs even when there is nothing new to commit.
- Run repos **one at a time**, not in parallel.

---

## Step 3 — Track results

| Outcome | Classification |
|---|---|
| All commands succeeded | **Success** |
| Output contains `SKIP_COMMIT_nothing_to_commit` and push succeeded | **Success** (already up to date) |
| `git pull` failed | **Failed** — skip remaining steps for this repo |
| `git push` or `git commit` failed (not "nothing to commit") | **Failed** |

**On failure:** capture exact error output, do NOT retry or fix automatically, move to next repo.

---

## Step 4 — Report

```
## Sync Report — YYYY-MM-DD HH:MM

### Synced successfully ✓
- skills-by-zj
- my-project (nothing to commit, already up to date)

### Failed — needs your attention ✗
- broken-repo
  Step: git pull
  Error: <exact error output here>
```

---

## Hard constraints

- Only operate inside `~/Documents/gitlocal`. Never touch anything outside.
- Do not install packages, tools, or modify any system/git/SSH configuration.
- Do not use `--force`, `--force-with-lease`, or any destructive git flag.
- Do not autonomously resolve merge conflicts or diverged branches — report them to the user.
