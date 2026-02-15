---
name: student-app-starter
description: >
  Guided app builder for students. Walks through picking a tech stack,
  scaffolding a project, and building a first working feature with
  AI agent assistance. Trigger: "build my app", "start my app",
  "student starter", or /student-app-starter.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Task, WebFetch, TodoWrite
context: fork
---
# ©2026 Brad Scheller

# Student App Starter

Guided, step-by-step skill that helps students go from an idea to a working application. Handles tech stack selection, project scaffolding, first feature implementation, and teaches how to use the AI agents along the way.

## When to Use This Skill

- Student says "build my app", "start my app", "I want to build...", or similar
- Student has an idea but doesn't know where to start
- Student wants to scaffold a new project with a recommended stack
- First-time user of ProdDevIQ / GODMODEDEV

## Process

### Step 1: What Are You Building?

Ask the student these questions (use AskUserQuestion):

1. **What's your app idea?** (one sentence is fine)
2. **What type of app?**
   - Web app (runs in a browser)
   - API / backend service
   - Mobile app
   - CLI tool
   - Something else
3. **Experience level?**
   - Beginner (first real project)
   - Intermediate (built a few things before)
   - Advanced (comfortable with frameworks)

### Step 2: Recommend a Tech Stack

Based on their answers, recommend ONE clear stack. Don't overwhelm with options.

**For beginners:**

| App Type | Recommended Stack | Why |
|----------|------------------|-----|
| Web app | **Next.js** (React + built-in routing + API routes) | One framework does frontend + backend. Huge community. |
| API | **Express.js** (Node.js) | Minimal, easy to understand, tons of tutorials. |
| Mobile | **Expo** (React Native) | Write once, runs on iOS + Android. JavaScript based. |
| CLI tool | **Node.js** with `commander` | Simple, no framework overhead. |

**For intermediate/advanced:**

| App Type | Options |
|----------|---------|
| Web app | Next.js, Remix, SvelteKit, Astro |
| API | Express, Fastify, Hono, Flask (Python), FastAPI (Python) |
| Mobile | Expo, React Native CLI, Flutter |
| Full-stack | Next.js (full-stack), T3 Stack (Next + tRPC + Prisma) |

Present the recommendation and ask: **"Sound good, or would you prefer something else?"**

### Step 3: Scaffold the Project

Once the student confirms, scaffold the project.

**Next.js (most common):**
```bash
npx create-next-app@latest {project-name} --typescript --tailwind --eslint --app --src-dir --import-alias "@/*"
cd {project-name}
```

**Express API:**
```bash
mkdir {project-name} && cd {project-name}
npm init -y
npm install express cors dotenv
mkdir src
```
Create a starter `src/index.js`:
```javascript
const express = require('express');
const cors = require('cors');
const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.get('/', (req, res) => {
  res.json({ message: 'API is running' });
});

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
```

**Expo (React Native):**
```bash
npx create-expo-app@latest {project-name}
cd {project-name}
```

**Python FastAPI:**
```bash
mkdir {project-name} && cd {project-name}
python3 -m venv venv
# Mac/Linux:
source venv/bin/activate
# Windows:
# venv\Scripts\activate
pip install fastapi uvicorn
mkdir app
```
Create starter `app/main.py`:
```python
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def root():
    return {"message": "API is running"}
```

After scaffolding, run the health/smoke test to confirm it works:
- **Next.js:** `npm run dev` (should see localhost:3000)
- **Express:** `node src/index.js` (should see localhost:3000)
- **Expo:** `npx expo start`
- **FastAPI:** `uvicorn app.main:app --reload`

Tell the student: **"Your project is running. Let's build your first feature."**

### Step 4: Set Up GODMODEDEV (Optional)

Ask: **"Want to set up AI agents for this project? They can help you code, review, test, and debug."**

If yes:
1. Create `.claude/` directory structure in their project
2. Copy CLAUDE.md template with their project name filled in
3. Deploy agents via `/agents-deploy`
4. Briefly explain: "You now have 10 AI specialists. Use `/delegate coder 'build the login page'` to send work to the coder, or `/delegate reviewer 'check my code'` for a code review."

If no: skip, continue to Step 5.

### Step 5: Build the First Feature

Ask: **"What's the first thing your app should do?"**

Guide them to describe it simply. Then:

1. Break it into 2-4 small tasks using TodoWrite
2. Work through each task with the student
3. After each task, show them what was created and explain the key parts
4. Run the app to demonstrate the feature working

**Example flow for a "user registration" feature in Next.js:**
```
Todo 1: Create the signup form component
Todo 2: Add form validation
Todo 3: Create the API route to handle registration
Todo 4: Connect form to API and test
```

### Step 6: Teach the Workflow

After the first feature is complete, briefly teach the student the development loop:

```
1. Describe what you want to build
2. Let Claude (or /delegate to an agent) implement it
3. Review what was created — ask questions if anything is unclear
4. Test it — run the app, try the feature
5. Iterate — ask for changes, fixes, improvements
```

Mention key commands they can use going forward:
- **"help me build..."** — describe any feature in plain language
- `/delegate coder "..."` — hand off implementation to the coder agent
- `/delegate reviewer "..."` — get a code review
- `/status` — check project progress (if orchestrator is set up)

### Step 7: Summary and Next Steps

Show what was accomplished:
```
Project: {name}
Stack: {stack}
Location: {path}
First feature: {description}
Agents: {deployed / not deployed}
```

Suggest what to build next based on their app idea. Give 2-3 concrete next features.

## Error Handling

- **`npx create-next-app` fails:** Check Node version (`node --version`, needs 18+). Try `npm cache clean --force`.
- **Port already in use:** Kill the process or use a different port (`PORT=3001 npm run dev`)
- **Python not found:** Check `python3 --version`. On Windows, might need `python` instead of `python3`.
- **Permission errors (Mac):** Use `sudo` for global installs, or fix npm permissions with `npm config set prefix ~/.npm-global`
- **Student is lost:** Slow down. Explain what each file does. Show the app running after every change.

## Teaching Notes

- Always explain *why*, not just *what*. Students learn more from understanding the reason behind each choice.
- Keep the first feature small. A working "hello world+" is better than an ambitious half-finished feature.
- Encourage students to read the generated code. Point out the important lines.
- If a student wants to use a stack you didn't recommend, let them. Autonomy builds confidence.
