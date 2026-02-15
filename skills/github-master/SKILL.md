---
name: github-master
description: >
  Comprehensive GitHub guide covering Actions CI/CD, release management,
  multi-repo workflows, project management, and automation patterns.
  Consolidates 5 GitHub skills.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Task, AskUserQuestion
context: fork
---

# ©2026 Brad Scheller

# GitHub Master Skill

Comprehensive guide for GitHub workflows, CI/CD pipelines, release automation, multi-repository patterns, project management, and security best practices.

## When to Use This Skill

Use this skill when you need to:
- Set up GitHub Actions CI/CD pipelines
- Automate releases with semantic versioning and changelogs
- Coordinate multi-repository workflows
- Configure branch protection and security policies
- Manage GitHub Projects (Issues, Labels, Milestones)
- Create reusable workflow templates
- Implement automation recipes (auto-labeling, stale bots, deploy previews)
- Use GitHub CLI for scripting and automation
- Set up code scanning, secret scanning, and dependency review

**Trigger phrases:**
- "set up GitHub Actions"
- "automate releases"
- "configure CI/CD pipeline"
- "create reusable workflow"
- "set up branch protection"
- "automate GitHub issues"
- "configure Dependabot"
- "set up CodeQL scanning"

---

## 1. GitHub Actions Fundamentals

### Workflow Syntax

**Basic structure:**
```yaml
name: CI Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]
  workflow_dispatch:  # Manual trigger

env:
  NODE_VERSION: '20'

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
      - run: npm ci
      - run: npm test
```

### Common Triggers

```yaml
on:
  push:
    branches: [main]
    paths:
      - 'src/**'
      - 'package.json'
    tags:
      - 'v*'

  pull_request:
    types: [opened, synchronize, reopened]

  schedule:
    - cron: '0 2 * * *'  # Daily at 2 AM UTC

  workflow_dispatch:
    inputs:
      environment:
        description: 'Deployment environment'
        required: true
        type: choice
        options: [staging, production]

  repository_dispatch:
    types: [deploy-request]
```

### Matrix Builds

```yaml
jobs:
  test:
    strategy:
      matrix:
        node-version: [18, 20, 22]
        os: [ubuntu-latest, windows-latest, macos-latest]
      fail-fast: false  # Continue even if one fails

    runs-on: ${{ matrix.os }}

    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
      - run: npm ci
      - run: npm test
```

### Secrets and Environment Variables

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production  # Requires environment approval

    steps:
      - name: Deploy
        env:
          API_KEY: ${{ secrets.API_KEY }}
          DEPLOY_URL: ${{ vars.DEPLOY_URL }}
        run: |
          echo "Deploying to $DEPLOY_URL"
          # Secrets are masked in logs
```

### Job Dependencies

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - run: npm run build

  test:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - run: npm test

  deploy:
    needs: [build, test]
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - run: npm run deploy
```

### Artifacts and Caching

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      # Cache dependencies
      - uses: actions/cache@v4
        with:
          path: ~/.npm
          key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
          restore-keys: |
            ${{ runner.os }}-node-

      - run: npm ci
      - run: npm run build

      # Upload build artifacts
      - uses: actions/upload-artifact@v4
        with:
          name: build-output
          path: dist/
          retention-days: 7

  deploy:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - uses: actions/download-artifact@v4
        with:
          name: build-output
          path: dist/
      - run: npm run deploy
```

---

## 2. CI/CD Templates

### Node.js Pipeline (Lint + Test + Build + Deploy)

```yaml
name: Node.js CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm run lint
      - run: npm run type-check

  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [18, 20, 22]
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: 'npm'
      - run: npm ci
      - run: npm test -- --coverage
      - uses: codecov/codecov-action@v4
        if: matrix.node-version == '20'
        with:
          token: ${{ secrets.CODECOV_TOKEN }}

  build:
    needs: [lint, test]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm run build
      - uses: actions/upload-artifact@v4
        with:
          name: build
          path: dist/

  deploy:
    needs: build
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    environment: production
    steps:
      - uses: actions/checkout@v4
      - uses: actions/download-artifact@v4
        with:
          name: build
          path: dist/
      - name: Deploy to Vercel
        env:
          VERCEL_TOKEN: ${{ secrets.VERCEL_TOKEN }}
          VERCEL_ORG_ID: ${{ secrets.VERCEL_ORG_ID }}
          VERCEL_PROJECT_ID: ${{ secrets.VERCEL_PROJECT_ID }}
        run: |
          npx vercel --prod --token=$VERCEL_TOKEN
```

### Python Pipeline (pytest + mypy + deploy)

```yaml
name: Python CI/CD

on:
  push:
    branches: [main]
  pull_request:

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ['3.10', '3.11', '3.12']

    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}
          cache: 'pip'

      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install pytest pytest-cov mypy ruff

      - name: Lint with ruff
        run: ruff check .

      - name: Type check with mypy
        run: mypy src/

      - name: Test with pytest
        run: |
          pytest --cov=src --cov-report=xml --cov-report=term

      - uses: codecov/codecov-action@v4
        if: matrix.python-version == '3.11'

  deploy:
    needs: test
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.11'

      - name: Build package
        run: |
          pip install build
          python -m build

      - name: Publish to PyPI
        if: startsWith(github.ref, 'refs/tags/v')
        env:
          TWINE_USERNAME: __token__
          TWINE_PASSWORD: ${{ secrets.PYPI_TOKEN }}
        run: |
          pip install twine
          twine upload dist/*
```

### Docker Pipeline (Build + Push)

```yaml
name: Docker Build & Push

on:
  push:
    branches: [main]
    tags: ['v*']
  pull_request:

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  build:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write

    steps:
      - uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Log in to Container Registry
        if: github.event_name != 'pull_request'
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=ref,event=branch
            type=ref,event=pr
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}
            type=sha

      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: ${{ github.event_name != 'pull_request' }}
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

---

## 3. Release Management

### Semantic Versioning Automation

**Using semantic-release:**

```yaml
name: Release

on:
  push:
    branches: [main]

jobs:
  release:
    runs-on: ubuntu-latest
    permissions:
      contents: write
      issues: write
      pull-requests: write

    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
          persist-credentials: false

      - uses: actions/setup-node@v4
        with:
          node-version: '20'

      - run: npm ci

      - name: Release
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          NPM_TOKEN: ${{ secrets.NPM_TOKEN }}
        run: npx semantic-release
```

**`.releaserc.json` configuration:**

```json
{
  "branches": ["main"],
  "plugins": [
    "@semantic-release/commit-analyzer",
    "@semantic-release/release-notes-generator",
    "@semantic-release/changelog",
    "@semantic-release/npm",
    "@semantic-release/github",
    [
      "@semantic-release/git",
      {
        "assets": ["package.json", "CHANGELOG.md"],
        "message": "chore(release): ${nextRelease.version} [skip ci]\n\n${nextRelease.notes}"
      }
    ]
  ]
}
```

### Changesets Workflow

**For monorepos and manual release control:**

```yaml
name: Release with Changesets

on:
  push:
    branches: [main]

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'

      - run: npm ci

      - name: Create Release PR
        id: changesets
        uses: changesets/action@v1
        with:
          publish: npm run release
          commit: 'chore: version packages'
          title: 'chore: version packages'
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          NPM_TOKEN: ${{ secrets.NPM_TOKEN }}
```

### GitHub Releases API

**Create release with gh CLI:**

```bash
# Create release from tag
gh release create v1.2.3 \
  --title "v1.2.3" \
  --notes-file CHANGELOG.md \
  --draft

# Upload release assets
gh release upload v1.2.3 dist/*.tar.gz

# Publish draft release
gh release edit v1.2.3 --draft=false
```

**Automated release notes:**

```yaml
- name: Generate release notes
  id: notes
  uses: actions/github-script@v7
  with:
    script: |
      const { data } = await github.rest.repos.generateReleaseNotes({
        owner: context.repo.owner,
        repo: context.repo.repo,
        tag_name: '${{ github.ref_name }}'
      });
      return data.body;
    result-encoding: string

- name: Create release
  run: |
    gh release create ${{ github.ref_name }} \
      --title "${{ github.ref_name }}" \
      --notes "${{ steps.notes.outputs.result }}"
```

---

## 4. Multi-Repo Workflows

### Repository Dispatch (Cross-Repo Triggers)

**Trigger workflow in another repo:**

```yaml
# In source repo
- name: Trigger downstream deploy
  run: |
    gh api repos/${{ github.repository_owner }}/target-repo/dispatches \
      --method POST \
      --field event_type=deploy-request \
      --field client_payload[version]=${{ github.ref_name }} \
      --field client_payload[source_repo]=${{ github.repository }}
  env:
    GITHUB_TOKEN: ${{ secrets.PAT_TOKEN }}  # Needs repo scope
```

**Receive dispatch in target repo:**

```yaml
# In target repo
on:
  repository_dispatch:
    types: [deploy-request]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Deploy version
        run: |
          echo "Deploying ${{ github.event.client_payload.version }}"
          echo "From ${{ github.event.client_payload.source_repo }}"
```

### Reusable Workflows

**Define reusable workflow (`.github/workflows/reusable-test.yml`):**

```yaml
name: Reusable Test Workflow

on:
  workflow_call:
    inputs:
      node-version:
        required: true
        type: string
      working-directory:
        required: false
        type: string
        default: '.'
    secrets:
      npm-token:
        required: false

jobs:
  test:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: ${{ inputs.working-directory }}

    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ inputs.node-version }}
      - run: npm ci
      - run: npm test
```

**Call reusable workflow:**

```yaml
jobs:
  test-backend:
    uses: ./.github/workflows/reusable-test.yml
    with:
      node-version: '20'
      working-directory: './backend'
    secrets:
      npm-token: ${{ secrets.NPM_TOKEN }}

  test-frontend:
    uses: ./.github/workflows/reusable-test.yml
    with:
      node-version: '20'
      working-directory: './frontend'
```

### Composite Actions

**Create composite action (`.github/actions/setup-env/action.yml`):**

```yaml
name: Setup Environment
description: Install dependencies and configure environment

inputs:
  node-version:
    description: 'Node.js version'
    required: true
    default: '20'

outputs:
  cache-hit:
    description: 'Whether npm cache was hit'
    value: ${{ steps.cache.outputs.cache-hit }}

runs:
  using: composite
  steps:
    - uses: actions/setup-node@v4
      with:
        node-version: ${{ inputs.node-version }}
        cache: 'npm'

    - id: cache
      uses: actions/cache@v4
      with:
        path: node_modules
        key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}

    - if: steps.cache.outputs.cache-hit != 'true'
      shell: bash
      run: npm ci
```

**Use composite action:**

```yaml
steps:
  - uses: actions/checkout@v4
  - uses: ./.github/actions/setup-env
    with:
      node-version: '20'
```

### Monorepo Patterns

**Selective CI based on changed paths:**

```yaml
jobs:
  detect-changes:
    runs-on: ubuntu-latest
    outputs:
      backend: ${{ steps.filter.outputs.backend }}
      frontend: ${{ steps.filter.outputs.frontend }}
    steps:
      - uses: actions/checkout@v4
      - uses: dorny/paths-filter@v3
        id: filter
        with:
          filters: |
            backend:
              - 'apps/backend/**'
              - 'packages/shared/**'
            frontend:
              - 'apps/frontend/**'
              - 'packages/ui/**'

  test-backend:
    needs: detect-changes
    if: needs.detect-changes.outputs.backend == 'true'
    runs-on: ubuntu-latest
    steps:
      - run: npm test --workspace=backend

  test-frontend:
    needs: detect-changes
    if: needs.detect-changes.outputs.frontend == 'true'
    runs-on: ubuntu-latest
    steps:
      - run: npm test --workspace=frontend
```

---

## 5. GitHub Project Management

### GitHub CLI for Issues and PRs

**Create issue:**

```bash
gh issue create \
  --title "Bug: Login fails on Safari" \
  --body "Detailed description" \
  --label bug,priority:high \
  --assignee @me \
  --milestone v1.2
```

**Create PR:**

```bash
gh pr create \
  --title "feat: add user authentication" \
  --body "Implements JWT-based auth" \
  --base main \
  --head feature/auth \
  --label enhancement \
  --reviewer @teammate
```

**List and filter:**

```bash
# List open PRs assigned to me
gh pr list --assignee @me --state open

# List issues with label
gh issue list --label bug --state open

# Search issues
gh issue list --search "login in:title"
```

**Bulk operations:**

```bash
# Close all stale issues
gh issue list --label stale --json number --jq '.[].number' | \
  xargs -I {} gh issue close {}

# Auto-merge approved PRs
gh pr list --search "review:approved" --json number --jq '.[].number' | \
  xargs -I {} gh pr merge {} --auto --squash
```

### GitHub Projects (v2) Automation

**Add issue to project:**

```bash
PROJECT_ID=$(gh project list --owner myorg --format json | jq -r '.[0].id')
ISSUE_ID=$(gh issue view 123 --json id --jq '.id')

gh project item-add $PROJECT_ID --owner myorg --content-id $ISSUE_ID
```

**Update project fields:**

```bash
# Set status field
gh project item-edit --id ITEM_ID --field-id FIELD_ID --project-id PROJECT_ID --text "In Progress"
```

**Automated workflow:**

```yaml
- name: Add to project
  uses: actions/add-to-project@v0.5.0
  with:
    project-url: https://github.com/orgs/myorg/projects/1
    github-token: ${{ secrets.PAT_TOKEN }}
```

### Labels and Milestones

**Create labels:**

```bash
gh label create "priority:high" --color FF0000 --description "High priority"
gh label create "type:feature" --color 0E8A16
gh label create "status:blocked" --color D93F0B
```

**Manage milestones:**

```bash
# Create milestone
gh api repos/:owner/:repo/milestones \
  --method POST \
  --field title="v1.2.0" \
  --field due_on="2026-03-01T00:00:00Z" \
  --field description="Q1 2026 release"

# List milestones
gh api repos/:owner/:repo/milestones --jq '.[] | "\(.title): \(.open_issues) open"'
```

---

## 6. Branch Protection

### Required Status Checks

**Configure via gh CLI:**

```bash
gh api repos/:owner/:repo/branches/main/protection \
  --method PUT \
  --field required_status_checks[strict]=true \
  --field required_status_checks[contexts][]=test \
  --field required_status_checks[contexts][]=lint \
  --field required_status_checks[contexts][]=build \
  --field enforce_admins=true \
  --field required_pull_request_reviews[required_approving_review_count]=2 \
  --field required_pull_request_reviews[dismiss_stale_reviews]=true \
  --field required_pull_request_reviews[require_code_owner_reviews]=true
```

### Auto-Merge Configuration

**Enable auto-merge in workflow:**

```yaml
- name: Enable auto-merge
  if: github.event_name == 'pull_request'
  run: gh pr merge --auto --squash ${{ github.event.pull_request.number }}
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Dependabot Configuration

**`.github/dependabot.yml`:**

```yaml
version: 2
updates:
  - package-ecosystem: npm
    directory: "/"
    schedule:
      interval: weekly
      day: monday
      time: "09:00"
    open-pull-requests-limit: 10
    reviewers:
      - my-team
    labels:
      - dependencies
      - automerge
    commit-message:
      prefix: "chore"
      prefix-development: "chore"
    ignore:
      - dependency-name: "eslint"
        versions: ["9.x"]

  - package-ecosystem: github-actions
    directory: "/"
    schedule:
      interval: monthly
    commit-message:
      prefix: "ci"
```

**Auto-approve Dependabot PRs:**

```yaml
name: Dependabot Auto-Approve

on:
  pull_request:
    types: [opened, reopened]

jobs:
  auto-approve:
    if: github.actor == 'dependabot[bot]'
    runs-on: ubuntu-latest
    permissions:
      pull-requests: write
    steps:
      - uses: hmarr/auto-approve-action@v3
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
```

---

## 7. GitHub CLI (gh) Scripting

### Common Commands

```bash
# Authentication
gh auth login
gh auth status

# Repository
gh repo create myproject --public --source=. --remote=origin
gh repo clone owner/repo
gh repo view --web

# Issues
gh issue create --title "Bug report" --body "Details"
gh issue list --assignee @me --label bug
gh issue view 123 --web
gh issue close 123 --comment "Fixed in v1.2"

# Pull Requests
gh pr create --fill  # Use commit messages
gh pr list --author @me
gh pr checkout 456
gh pr review 456 --approve --body "LGTM"
gh pr merge 456 --squash --delete-branch

# Workflows
gh workflow list
gh workflow run ci.yml --ref feature-branch
gh run list --workflow=ci.yml
gh run watch
gh run view 123456 --log

# Releases
gh release create v1.0.0 --notes "Initial release"
gh release upload v1.0.0 dist/*.zip
gh release list

# API access
gh api repos/:owner/:repo/issues
gh api graphql -f query='query { viewer { login }}'
```

### Scripting Examples

**Bulk PR updates:**

```bash
#!/bin/bash
# Add label to all open PRs with "WIP" in title

gh pr list --state open --json number,title --jq '.[] | select(.title | contains("WIP")) | .number' | \
while read -r pr_number; do
  gh pr edit "$pr_number" --add-label "work-in-progress"
done
```

**Automated release checklist:**

```bash
#!/bin/bash
# Pre-release validation

echo "Running pre-release checks..."

# Check CI status
if ! gh pr checks --watch; then
  echo "CI checks failed"
  exit 1
fi

# Check for open blockers
BLOCKERS=$(gh issue list --label blocker --state open --json number --jq '. | length')
if [ "$BLOCKERS" -gt 0 ]; then
  echo "Found $BLOCKERS blocking issues"
  exit 1
fi

# Create release
VERSION=$(node -p "require('./package.json').version")
gh release create "v$VERSION" --generate-notes
```

---

## 8. Automation Recipes

### Auto-Label PRs

```yaml
name: Auto Label PRs

on:
  pull_request:
    types: [opened, edited]

jobs:
  label:
    runs-on: ubuntu-latest
    permissions:
      pull-requests: write
    steps:
      - uses: actions/labeler@v5
        with:
          repo-token: ${{ secrets.GITHUB_TOKEN }}
```

**`.github/labeler.yml`:**

```yaml
'backend':
  - changed-files:
    - any-glob-to-any-file: 'backend/**/*'

'frontend':
  - changed-files:
    - any-glob-to-any-file: 'frontend/**/*'

'documentation':
  - changed-files:
    - any-glob-to-any-file: ['docs/**/*', '**/*.md']

'dependencies':
  - changed-files:
    - any-glob-to-any-file: ['package.json', 'package-lock.json', 'yarn.lock', 'pnpm-lock.yaml']
```

### Stale Issue Bot

```yaml
name: Close Stale Issues

on:
  schedule:
    - cron: '0 0 * * *'  # Daily
  workflow_dispatch:

jobs:
  stale:
    runs-on: ubuntu-latest
    permissions:
      issues: write
      pull-requests: write
    steps:
      - uses: actions/stale@v9
        with:
          stale-issue-message: 'This issue has been inactive for 60 days and will close in 7 days without activity.'
          close-issue-message: 'Closing due to inactivity.'
          days-before-stale: 60
          days-before-close: 7
          stale-issue-label: 'stale'
          exempt-issue-labels: 'pinned,security,roadmap'
          exempt-assignees: true
```

### PR Size Check

```yaml
name: PR Size Check

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  size-check:
    runs-on: ubuntu-latest
    permissions:
      pull-requests: write
    steps:
      - uses: actions/checkout@v4

      - name: Check PR size
        id: check
        run: |
          FILES_CHANGED=$(gh pr view ${{ github.event.pull_request.number }} --json files --jq '.files | length')
          ADDITIONS=$(gh pr view ${{ github.event.pull_request.number }} --json additions --jq '.additions')

          if [ "$FILES_CHANGED" -gt 50 ] || [ "$ADDITIONS" -gt 1000 ]; then
            echo "size=large" >> $GITHUB_OUTPUT
            echo "This PR is large. Consider splitting it."
          elif [ "$FILES_CHANGED" -gt 20 ] || [ "$ADDITIONS" -gt 500 ]; then
            echo "size=medium" >> $GITHUB_OUTPUT
          else
            echo "size=small" >> $GITHUB_OUTPUT
          fi
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - name: Add label
        run: |
          gh pr edit ${{ github.event.pull_request.number }} --add-label "size:${{ steps.check.outputs.size }}"
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Deploy Previews

```yaml
name: Deploy Preview

on:
  pull_request:
    types: [opened, synchronize, reopened]

jobs:
  deploy-preview:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Deploy to preview environment
        id: deploy
        run: |
          # Deploy logic (Vercel, Netlify, etc.)
          PREVIEW_URL="https://pr-${{ github.event.pull_request.number }}.preview.example.com"
          echo "url=$PREVIEW_URL" >> $GITHUB_OUTPUT

      - name: Comment PR
        uses: actions/github-script@v7
        with:
          script: |
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: `🚀 Preview deployed to: ${{ steps.deploy.outputs.url }}`
            })
```

---

## 9. Security

### Secret Scanning

**Enable via gh CLI:**

```bash
gh api repos/:owner/:repo \
  --method PATCH \
  --field security_and_analysis[secret_scanning][status]=enabled \
  --field security_and_analysis[secret_scanning_push_protection][status]=enabled
```

**Custom secret patterns (`.github/secret_scanning.yml`):**

```yaml
patterns:
  - name: Internal API Key
    pattern: 'INTERNAL_API_[A-Z0-9]{32}'

  - name: Database URL
    pattern: 'postgres://[^:]+:[^@]+@[^/]+/[^\s]+'
```

### CodeQL Scanning

**`.github/workflows/codeql.yml`:**

```yaml
name: CodeQL Security Scan

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  schedule:
    - cron: '0 6 * * 1'  # Weekly Monday 6 AM

jobs:
  analyze:
    runs-on: ubuntu-latest
    permissions:
      security-events: write
      actions: read
      contents: read

    strategy:
      matrix:
        language: [javascript, python]

    steps:
      - uses: actions/checkout@v4

      - uses: github/codeql-action/init@v3
        with:
          languages: ${{ matrix.language }}
          queries: security-extended

      - uses: github/codeql-action/autobuild@v3

      - uses: github/codeql-action/analyze@v3
        with:
          category: "/language:${{ matrix.language }}"
```

### Dependency Review

```yaml
name: Dependency Review

on:
  pull_request:

jobs:
  dependency-review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/dependency-review-action@v4
        with:
          fail-on-severity: high
          deny-licenses: GPL-3.0, AGPL-3.0
          allow-licenses: MIT, Apache-2.0, BSD-3-Clause
```

### CODEOWNERS

**`.github/CODEOWNERS`:**

```
# Global owners
* @core-team

# Backend
/backend/ @backend-team
/api/ @backend-team @security-team

# Frontend
/frontend/ @frontend-team
/components/ @frontend-team @design-team

# Infrastructure
/docker/ @devops-team
/.github/workflows/ @devops-team @security-team
/terraform/ @devops-team

# Documentation
/docs/ @tech-writers
*.md @tech-writers

# Security-sensitive
/auth/ @security-team
/crypto/ @security-team
```

---

## Best Practices

1. **Workflow organization:**
   - Use reusable workflows for repeated patterns
   - Keep workflows focused (separate CI, CD, security)
   - Use composite actions for multi-step setup tasks

2. **Security:**
   - Never commit secrets — use GitHub Secrets
   - Enable secret scanning and push protection
   - Use CODEOWNERS for sensitive paths
   - Run CodeQL on all PRs

3. **Performance:**
   - Cache dependencies aggressively
   - Use matrix builds efficiently
   - Upload/download artifacts between jobs
   - Use `paths` filters to skip unnecessary workflows

4. **Release management:**
   - Automate semantic versioning
   - Generate release notes automatically
   - Use changesets for manual control in monorepos

5. **Multi-repo coordination:**
   - Use repository dispatch for cross-repo triggers
   - Share reusable workflows across org
   - Use composite actions for shared setup

6. **Project management:**
   - Use GitHub Projects (v2) for roadmaps
   - Automate issue triaging with labels
   - Set up Dependabot with auto-merge
   - Use gh CLI for bulk operations

---

## Related Skills

- `vercel-react-best-practices` — Vercel deployment patterns
- `agent-browser` — Browser automation for E2E testing
- `unified-orchestrator` — Multi-agent project orchestration
- `web-design-guidelines` — UI/UX review automation

---

## References

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitHub CLI Manual](https://cli.github.com/manual/)
- [Semantic Release](https://semantic-release.gitbook.io/)
- [Changesets](https://github.com/changesets/changesets)
- [CodeQL](https://codeql.github.com/docs/)
