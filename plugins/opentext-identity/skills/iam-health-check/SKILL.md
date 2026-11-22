---
name: iam-health-check
description: >
  Use when running or writing up a periodic health check of an OpenText (NetIQ) Identity
  Manager and/or Access Manager environment: eDirectory time and replica sync, driver state
  and queued events, iManager / Identity Console, SSPR, Identity Applications, workflows
  ended in error, Access Manager components and certificates. Guides the check item by item,
  never assumes a status, and produces a report as Markdown, HTML or plain text.
license: Apache-2.0
---

# iam-health-check

## Purpose

Run a structured **health check** of an IDM / NAM environment together with the user, and produce a report ready to paste into a ticket, email or wiki.

Rules:
1. **Never assume a status.** Ask for each item and wait for an explicit answer, or run the check yourself only if you have access and the user allows it.
2. **Read-only.** A health check observes. Fixes are proposed, never applied without explicit approval.
3. **Generic.** No customer names or hostnames stay in the skill. The user supplies them per run.

## Local knowledge base (optional)

Before answering from memory, check whether the user configured a knowledge base:

1. The environment variable `AGENT_KB_DIR` (a folder of notes or docs), or
2. A "Knowledge base" section in `CLAUDE.md` / `AGENTS.md` naming a path or a skill to use for reading it.

If one exists, look there for the user's own check catalog, report template or known-error runbooks, and prefer them. Otherwise use the defaults below. Never write to the knowledge base unless the user asks.

---

## Default check catalog

### IDM (core)

| # | Check | How to verify |
|---|---|---|
| 1 | eDirectory time synchronization | `ndsrepair -T`: all servers in sync |
| 2 | eDirectory replica synchronization | `ndsrepair -E`: no errors, recent sync time per replica |
| 3 | Drivers running, no backlog | iManager / Identity Console → Identity Manager overview: driver state, queued events. `dxcmd -getstate <driver-dn>` |
| 4 | Remote Loaders reachable | Driver status, Remote Loader service on the remote host |
| 5 | iManager / Identity Console | Log in on every instance |
| 6 | SSPR | URL reachable, login works, TLS certificate valid |
| 7 | Identity Applications | Dashboard/portal login, forms open, TLS certificate valid |
| 8 | Workflows ended in error | Workflow administration: filter the last N days by error status and read the comments |
| 9 | Disk, CPU, memory on servers | `df -h`, `free -m`, `top`. Log partitions not full |
| 10 | Certificates close to expiry | `openssl s_client` / keystore listing, with a threshold (e.g. 30 days) |

### Access Manager (optional)

| # | Check | How to verify |
|---|---|---|
| 11 | Administration Console | Login works, devices show healthy |
| 12 | Identity Server | `https://<idp>/nidp/heartbeat` returns 200, health is green |
| 13 | Access Gateway | `https://<ag>/nesp/app/heartbeat` returns 200, proxies without errors |
| 14 | Analytics | Dashboard loads, disk usage OK |

### Custom items

At the start, the user can add items: other integrations, batch jobs, HR feeds and so on. They are appended at the end.

---

## Flow

### 1. Setup

Ask, one question at a time, only for what is missing:
- Report title or identifier (e.g. environment name)
- Ticket or reference ID (optional)
- Date (default: today)
- Include Access Manager? Any custom items?
- Output format: **Markdown** (default), **HTML** (`assets/report-template.html`) or **plain text**

### 2. Go through the items

For each item:

```
🔍 <Check> — How: <verification>
Status? [OK / WARNING / ERROR / N/A / SKIP]
```

- **WARNING / ERROR**: ask for a short detail. Offer to research it: knowledge base first, then official docs and KB articles (see `idm-identity-servers`, `idm-identity-drivers`, `nam-access-manager`, `enterprise-certificates`). Show a short summary with the source link.
- **SKIP**: omit the item from the report.

### 3. Report

Markdown default:

```markdown
## Health check — <title> — <date>
Reference: <ticket>

| Status | Check | Detail |
|---|---|---|
| ✅ OK | eDirectory time synchronization | |
| ❌ ERROR | Drivers running, no backlog | AD driver with 1,200 queued events |
| ➖ N/A | Analytics | |

**Notes:** <free text>
**Recommended actions:** <one line per WARNING/ERROR>
```

For HTML, fill `assets/report-template.html` (one row per item, using the status classes). Print the result in a code block so the user can copy it. Write it to a file only if the user asks.

### 4. Close

Offer: regenerate in another format, add notes, or save the report.
