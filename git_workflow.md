# SmashLand — Git Workflow

## Checkpoint Commit Process

When the user says **"Please commit everything"**, follow this exact sequence:

### Step 1 — Status Check
```bash
git status
```
Review untracked and modified files. If nothing changed, report "Nothing to commit" and stop.

### Step 2 — Secret Scan (CRITICAL)
Before staging ANY files, scan the workspace for:

| Pattern | Risk |
|---------|------|
| `.env`, `.env.*` | Environment secrets |
| `*.key`, `*.pem`, `*.p12`, `*.pfx` | Private keys / certificates |
| `API_KEY`, `SECRET`, `TOKEN`, `PASSWORD` in file contents | Hardcoded credentials |
| `PRIVATE KEY` block in any file | Embedded private key |
| `oauth`, `credential`, `secret` in filenames | OAuth / cloud secrets |
| `*.db`, `*.sqlite` | Database files with potential data |

**If ANY suspicious content is found:**
1. **STOP** — do not stage or commit
2. **Warn the user** with the file list
3. **Recommend** adding files to `.gitignore`
4. **Wait** for explicit user confirmation before proceeding

### Step 3 — Stage Files
```bash
git add <specific files>
```
Prefer explicit file names over `git add -A`. Never blindly stage everything.

### Step 4 — Commit
```bash
git commit -m "chore(checkpoint): update progress + dashboards"
```

### Step 5 — Push (Conditional)
Push **only if**:
- A remote `origin` exists (`git remote -v`)
- Authentication is configured
- Push succeeds without error

If push fails, print the exact error and next steps for the user. **Never claim push success without seeing confirmation output.**

---

## Commit Message Format

```
<type>(<scope>): <short description>

[optional body]

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
```

### Types
| Type | When |
|------|------|
| `feat` | New gameplay feature or system |
| `fix` | Bug fix |
| `refactor` | Code restructuring, no behavior change |
| `chore` | Tooling, config, dashboards, docs |
| `test` | Adding or updating tests |
| `art` | Asset additions (sprites, audio, etc.) |

### Scopes (examples)
`fighter`, `arena`, `camera`, `input`, `ui`, `select`, `checkpoint`

---

## Safety Warnings

### NEVER do these without explicit user request:
- `git push --force` (destroys remote history)
- `git reset --hard` (destroys local changes)
- `git checkout .` or `git restore .` (discards all modifications)
- `git clean -f` (deletes untracked files permanently)
- `git branch -D` (force-deletes a branch)
- `git rebase` on shared branches
- `--no-verify` on any git command (bypasses safety hooks)

### ALWAYS do these:
- Create NEW commits (don't amend unless explicitly asked)
- Stage specific files by name
- Run secret scan before every commit
- Verify push output before reporting success

---

## .gitignore Coverage

The `.gitignore` must protect against:
```
# Secrets and credentials
.env
.env.*
*.key
*.pem
*.p12
*.pfx

# Godot engine cache
.godot/

# Claude Code local config
.claude/

# Build artifacts
build/
dist/
export/
*.exe
*.x86_64
*.apk

# OS files
.DS_Store
Thumbs.db
desktop.ini

# Dependencies (if ever used)
node_modules/
```
