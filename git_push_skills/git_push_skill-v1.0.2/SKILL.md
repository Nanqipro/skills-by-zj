---
name: git-sync
description: >
  Use this skill to sync, push, pull, or upload local git repositories to remote (GitHub/remote).
  MUST trigger when user says any of: "帮我同步", "同步一下", "上传代码", "push一下", "push代码",
  "sync", "同步仓库", "上传到github", "push to github", "pull一下", "更新远程", "upload code",
  "push changes", "sync repos", "sync all", or any sentence containing push/pull/sync/upload
  combined with code/repo/仓库/代码/github. If user names a specific repo, sync only that one.
  If user says "all" or names no repo, sync every repo under /Users/nanpipro/Documents/gitlocal.
---

# git-sync

> **CRITICAL — READ BEFORE ANYTHING ELSE**
>
> You have a Bash tool. Use it. RIGHT NOW, before writing a single word of reply, call the Bash tool with this exact command:
>
> ```bash
> for d in /Users/nanpipro/Documents/gitlocal/*/; do [ -d "$d/.git" ] && basename "$d"; done
> ```
>
> Do NOT say "I cannot access", do NOT ask the user for the path, do NOT explain anything.
> The directory `/Users/nanpipro/Documents/gitlocal` exists on the user's local machine and
> the Bash tool can reach it directly. Just run the command and proceed.

This skill runs four git commands (`pull → add → commit → push`) on one or all local repositories under `/Users/nanpipro/Documents/gitlocal`.

---

## Step 1 — Identify target repos

First, get the full list of git repos available:
```bash
for d in /Users/nanpipro/Documents/gitlocal/*/; do [ -d "$d/.git" ] && basename "$d"; done
```

Then apply one of the three cases below:

---

### Case A — Exact repo name given
User says something like "sync skills-by-zj" or "push weekly_repo_skill_inGOODLAB".

- Check the name matches exactly (case-insensitive) against the repo list.
- If found: proceed to Step 2 with that single repo.
- If not found: fall through to Case B fuzzy match.

---

### Case B — Keyword / fuzzy match
User says something like "帮我同步有关skill的仓库", "sync the repo related to push", "同步跟weekly有关的".

Extract the keyword from the user's message, then run:
```bash
for d in /Users/nanpipro/Documents/gitlocal/*/; do
  [ -d "$d/.git" ] && basename "$d"
done | grep -i "<KEYWORD>"
```

**Interpret results:**
- **1 match** → proceed to Step 2 with that repo. Tell the user which repo was matched: "Matched: `<repo-name>`".
- **2+ matches** → list all matches and ask the user: "找到多个匹配的仓库，请确认要同步哪个：\n- repo-a\n- repo-b". Wait for confirmation before proceeding.
- **0 matches** → tell the user no repo matched the keyword, list all available repos, and stop.

---

### Case C — Sync all
User says "all", "全部", "所有仓库", or gives no repo name at all.

Use the full repo list from the initial Bash command. Proceed to Step 2 for every repo in the list.

---

## Step 2 — Sync each repo

For each target repo, run the following Bash command. Replace `<REPO_PATH>` with the full absolute path:

```bash
cd <REPO_PATH> && \
git pull 2>&1 && \
git add . 2>&1 && \
git diff --cached --quiet && echo "SKIP_COMMIT_nothing_to_commit" || git commit -m "$(date '+%Y-%m-%d')" 2>&1 && \
git push 2>&1
```

**Explanation of the commit line:**
- `git diff --cached --quiet` exits 0 if nothing is staged (nothing to commit).
- If nothing staged → print `SKIP_COMMIT_nothing_to_commit` and continue to push.
- If something is staged → run `git commit -m "YYYY-MM-DD"`.
- This ensures `git push` always runs even when there is nothing new to commit.

Run repos **one at a time** (not in parallel) so output is clear.

---

## Step 3 — Track results

As each repo finishes, classify it:

| Outcome | Classification |
|---|---|
| All commands succeeded | **Success** |
| Output contains `SKIP_COMMIT_nothing_to_commit` and push succeeded | **Success** (already up to date) |
| `git pull` failed | **Failed** — skip remaining steps for this repo |
| `git push` failed | **Failed** |
| Any other non-zero exit | **Failed** |

**When a command fails:**
- Capture the exact error text.
- Do NOT retry, do NOT force-push, do NOT rebase or resolve conflicts automatically.
- Move on to the next repo.

---

## Step 4 — Report

After all repos are processed, output this summary:

```
## Sync Report — YYYY-MM-DD HH:MM

### Synced successfully ✓
- skills-by-zj
- my-project (nothing to commit, already up to date)

### Failed — needs your attention ✗
- broken-repo
  Step: git pull
  Error: <exact error output>
```

If all repos succeeded, say so clearly. If any failed, remind the user to handle those manually.

---

## Hard constraints

- Only operate inside `/Users/nanpipro/Documents/gitlocal`. Never touch anything outside.
- Do not install packages, tools, or modify system/git/SSH configuration.
- Do not use `--force`, `--force-with-lease`, or any destructive git flag.
- Do not make autonomous decisions about conflicts or diverged branches — report them.
