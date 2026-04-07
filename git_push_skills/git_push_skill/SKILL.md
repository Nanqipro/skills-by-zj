---
name: git-sync
description: >
  Use this skill to sync, push, pull, or upload local git repositories to remote (GitHub/remote).
  MUST trigger when user says any of: "帮我同步", "同步一下", "上传代码", "push一下", "push代码",
  "sync", "同步仓库", "上传到github", "push to github", "pull一下", "更新远程", "upload code",
  "push changes", "sync repos", "sync all", or any sentence containing push/pull/sync/upload
  combined with code/repo/仓库/代码/github.
compatibility:
  tools:
    - Bash
---

# git-sync

> **This skill requires Claude Code** (VSCode extension or CLI).
> It uses the Bash tool to run a local shell script on your machine.
> It will NOT work in Claude.ai web or the Claude mobile app (no local filesystem access there).

All sync logic lives in a single script:
```
~/Documents/gitlocal/skills-by-zj/git_push_skills/git_push_skill/scripts/sync_repos.sh
```

Your only job is to call that script with the right arguments via the Bash tool.

---

## Step 1 — Parse user intent and call the script

### If user names a specific repo (exact or near-exact)
e.g. "sync skills-by-zj", "push weekly_repo_skill_inGOODLAB"

```bash
bash ~/Documents/gitlocal/skills-by-zj/git_push_skills/git_push_skill/scripts/sync_repos.sh <repo-name>
```

### If user gives a keyword / fuzzy description
e.g. "帮我同步有关skill的仓库", "sync the repo about weekly"

```bash
bash ~/Documents/gitlocal/skills-by-zj/git_push_skills/git_push_skill/scripts/sync_repos.sh --fuzzy <keyword>
```

If the script reports **multiple matches**, show the list to the user and ask which one to sync. Then re-run with the exact name.

### If user says "all", "全部", "所有", or names no repo

```bash
bash ~/Documents/gitlocal/skills-by-zj/git_push_skills/git_push_skill/scripts/sync_repos.sh
```

---

## Step 2 — Show the script output to the user

Paste the full output of the script into the chat. The script already produces a structured report:

```
✓ Synced successfully:   — repos that were committed and pushed
○ Already up to date:    — repos with nothing new to commit
✗ Failed:               — repos that errored, with exact error text
```

Do not summarize or paraphrase — show the raw output so the user sees exactly what happened.

---

## Hard constraints

- Do not modify any files outside `~/Documents/gitlocal`.
- Do not install packages or change system/git/SSH configuration.
- Do not use `--force` or any destructive git flag.
- Do not fix errors automatically — the script reports them; the user decides what to do.
