---
name: start-new-project
description: >
  Interactive new project setup wizard. Guides user through naming, repo import
  (clone, zip download, or combine multiple repos), directory setup, and then
  hands off to /init for orchestrator configuration. Trigger: "start new project"
  or /start-new-project.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Task, WebFetch, TodoWrite
context: fork
---
# ©2026 Brad Scheller

# Start New Project

Interactive wizard that sets up a new project workspace from scratch — including importing GitHub repositories — then hands off to the unified orchestrator `/init` flow.

## When to Use This Skill

- User says "start new project", "new project", "set up a project", or similar
- User wants to combine multiple GitHub repos into one workspace
- User wants to clone or download a repo and begin working in it
- User needs a guided walkthrough from zero to a configured GODMODEDEV project

## Process

### Step 1: Project Basics

Ask the user for:

1. **Project name** — will become the directory name (lowercase-hyphenated)
2. **Project location** — where to create it (default: current working directory)
3. **Brief description** — one-liner for config files

Present a summary and ask: **"Ready to create `{location}/{project-name}/`? (yes/no)"**

Do NOT create anything until the user confirms.

### Step 2: Repository Import

Ask the user:

> **Would you like to import any GitHub repositories?**
>
> 1. **Clone a repo** — `git clone` into the project directory
> 2. **Download as ZIP** — download and extract (no git history)
> 3. **Combine multiple repos** — import 2+ repos into subdirectories or merge into one
> 4. **Skip** — start with an empty project

#### Option 1: Clone a repo

```bash
git clone <repo-url> {project-name}
# or if project dir already created:
git clone <repo-url> {project-name}/{subdir}
```

- Accept full GitHub URLs (`https://github.com/owner/repo`) or shorthand (`owner/repo`)
- For shorthand, expand to `https://github.com/{owner}/{repo}.git`
- Ask if they want a specific branch: `git clone -b {branch} <url>`

#### Option 2: Download as ZIP

```bash
# Using GitHub CLI (preferred)
gh repo clone {owner}/{repo} -- --depth 1
# Then remove .git/ to detach history
rm -rf {project-name}/.git

# OR download ZIP via gh API
gh api repos/{owner}/{repo}/zipball/{branch} > repo.zip
# Extract with PowerShell
powershell -NoProfile -Command "Expand-Archive -Path repo.zip -DestinationPath {project-name} -Force"
# Clean up
rm repo.zip
```

- If the user uploads a .zip file directly, extract it into the project directory
- Handle nested directory structures (GitHub ZIPs often have a `{repo}-{branch}/` wrapper)

#### Option 3: Combine multiple repos

For each repo the user provides:

1. Ask: **"Import as subdirectory or merge into root?"**
   - **Subdirectory**: clone/extract into `{project-name}/{repo-name}/`
   - **Merge into root**: clone/extract then copy contents into project root (warn about conflicts)

2. Process repos sequentially. After each import, show what was added.

3. If merging into root with conflicts, list conflicting files and ask the user which version to keep.

After all imports:
- Initialize a fresh git repo if the project doesn't have one: `git init && git add -A && git commit -m "Initial commit: combined from imported repos"`
- Ask user before committing

#### Option 4: Skip

Create an empty project directory. Continue to Step 3.

### Step 3: GODMODEDEV Scaffolding

Ask the user:

> **Set up GODMODEDEV orchestrator for this project?**
>
> 1. **Yes, full setup** — create .claude/, deploy agents, initialize orchestrator
> 2. **Minimal** — just create CLAUDE.md from template
> 3. **Skip** — I'll configure it myself later

#### Full setup

1. Create project directory structure:
   ```
   {project-name}/
   ├── .claude/
   │   ├── rules/
   │   ├── agents/       (via /agents-deploy)
   │   └── settings.json (from template)
   ├── .orchestrator/    (via /init)
   └── CLAUDE.md         (from template)
   ```

2. Copy templates from `E:\GODMODEDEV\templates\new-project\`:
   - `CLAUDE.md.template` → `CLAUDE.md` (replace `{{PROJECT_NAME}}`, `{{PROJECT_DESCRIPTION}}`, `{{PROJECT_TYPE}}`, `{{PROJECT_LEVEL}}`)
   - `settings.json.template` → `.claude/settings.json`
   - `.mcp.json.template` → `.mcp.json` (if present)

3. Ask for project level:
   - **L0** — Quick fix (1 story)
   - **L1** — Small feature (1-10 stories)
   - **L2** — Medium (5-15 stories)
   - **L3** — Complex (12-40 stories)
   - **L4** — Enterprise (40+ stories)

4. Deploy agents: run the equivalent of `/agents-deploy`

5. Tell the user: **"Project scaffolded. Run `/init` inside the project to complete orchestrator setup, or I can run it now."**

#### Minimal setup

1. Copy `CLAUDE.md.template` with variable substitution
2. Create `.claude/rules/` directory
3. Done

### Step 4: Summary & Next Steps

Present a final summary:

```
Project: {project-name}
Location: {full-path}
Repos imported: {list or "none"}
GODMODEDEV setup: {full / minimal / skipped}
Agents deployed: {count or "no"}
```

Suggest next steps:
- `cd {project-name}` and open in Claude Code
- `/status` to see phase progress
- `/delegate` to start working with agents

## Error Handling

- **Git clone fails**: Check URL, suggest `gh auth login` if 403/404, offer ZIP fallback
- **ZIP extraction fails**: Try PowerShell `Expand-Archive`, then `tar -xf` as fallback
- **Directory already exists**: Ask to overwrite, merge, or pick a new name
- **No git installed**: Fall back to ZIP download via `gh` or `curl`
- **gh not authenticated**: Prompt `gh auth login` or fall back to HTTPS clone with credentials

## Script Helpers

### Clone with validation
```bash
# Validate repo exists before cloning
gh repo view {owner}/{repo} --json name,description,defaultBranchRef 2>/dev/null
```

### Download and extract ZIP
```bash
gh api repos/{owner}/{repo}/zipball/{branch} > /tmp/repo.zip
powershell -NoProfile -Command "Expand-Archive -Path /tmp/repo.zip -DestinationPath /tmp/repo-extract -Force"
# Move contents (skip wrapper directory)
mv /tmp/repo-extract/*/* {target-path}/
rm -rf /tmp/repo-extract /tmp/repo.zip
```

## Key Paths

| Item | Path |
|------|------|
| Templates | `E:\GODMODEDEV\templates\new-project\` |
| Agent source | `~/.agents/skills/unified-orchestrator/templates/agents/` |
| Deploy script | `E:\GODMODEDEV\scripts\deploy-agents.ps1` |
| Orchestrator config | `.orchestrator/config.yaml` |
