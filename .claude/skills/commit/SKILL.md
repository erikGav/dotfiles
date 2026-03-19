---
name: commit
description: Use when the user asks to commit changes in the dotfiles repo - stages and commits with a brief message, no co-author line
---

# commit

Review staged and unstaged changes, write a brief commit message describing what changed, and commit without a Co-Authored-By line.

## Steps

1. Run `git diff HEAD` to see all changes
2. Run `git status` to see untracked files
3. Stage relevant files by name (avoid `git add -A`)
4. Commit with a short, lowercase message — one line, no period, no author suffix

## Format

```
git commit -m "brief description of changes"
```

No `Co-Authored-By` line. No body. Just the message.
