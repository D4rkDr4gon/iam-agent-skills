# Customizing the skills

The skills are generic. You make them yours in three ways, from lightest to heaviest.

## 1. Connect your knowledge base (recommended)

Every skill has a **Local knowledge base (optional)** section. Before answering from memory, it looks for:

1. The environment variable **`AGENT_KB_DIR`**, which points to a folder of notes or docs (Markdown, text, exported PDFs, …), or
2. A **"Knowledge base"** section in your `CLAUDE.md` / `AGENTS.md`.

### Option A: environment variable

```bash
export AGENT_KB_DIR="$HOME/notes/iam"
```

### Option B: `CLAUDE.md` / `AGENTS.md` section

Use this option when your notes live in a tool that has its own skill or MCP server (Obsidian, Notion, Confluence, …), or when you want to map topics to folders:

```markdown
## Knowledge base

- Read it through the `my-notes` skill (or MCP server `notes`). Never write without asking.
- One Identity notes: `<root>/one-identity/`. Start from the index note `ONEIM - MAP.md`.
- OpenText IDM notes: `<root>/idm/` (known errors under `errors/`).
- Access Manager notes: `<root>/nam/`.
- Course syllabi: `<root>/courses/`. `oneim-manager` and `oneim-safeguard` switch to tutor mode when one exists.
- Workflow form conventions and in-house JS helpers: `<root>/idm/forms/`.
```

What the skills do with it:
- search it first and cite the note they used;
- prefer your runbooks, catalogs and conventions over generic defaults;
- write to it **only** when you explicitly ask.

Keep customer-specific material (hostnames, catalogs with real keys, internal libraries) **in your knowledge base**, not in a fork of this repo.

## 2. Add instructions without forking

In your project's or user's `CLAUDE.md` / `AGENTS.md`, you can add preferences the skills will respect. For example: "health checks: always include the HR feed job"; "answer in Spanish"; "our IDM is on RHEL 9, Identity Apps on a separate host".

## 3. Fork

If you need structural changes, fork the repo, edit the `SKILL.md` files and add your fork as a marketplace (`/plugin marketplace add <you>/iam-agent-skills`). Keep a private fork private if it contains anything about your environment.
