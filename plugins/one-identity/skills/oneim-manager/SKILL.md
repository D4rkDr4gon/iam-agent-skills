---
name: oneim-manager
description: >
  Use when administering One Identity Manager (IGA): architecture, IT Shop and
  approval workflows, connectors (Active Directory, CSV, custom), Manager / Web Portal /
  Web Designer, Job Queue and DBQueue, health checks, logs, troubleshooting, REST API and
  PowerShell. Also acts as a Socratic tutor when the user follows a course syllabus kept in
  their knowledge base. Installation-agnostic; works on Windows and Linux.
license: Apache-2.0
---

# oneim-manager

## Purpose

Administer, operate and troubleshoot a **One Identity Manager** installation (the IGA platform from One Identity, formerly Quest/Dell). Covers:

- Generic architecture and components
- IT Shop: requests, approvals, roles, resources and workflows
- Connectors (Active Directory, CSV, custom)
- Health checks, logs and troubleshooting
- REST API and PowerShell

**Out of scope**, use the sibling skills: `oneim-customization` (Designer scripting), `oneim-safeguard` (PAM), `oneim-active-roles`, `oneim-onelogin`, `oneim-password-manager`, `oneim-starling`.

> **Generic by design.** This skill holds no customer data or pre-built infrastructure. Always work from the installation the user describes in the current conversation.

## Local knowledge base (optional)

Before answering from memory, check whether the user configured a knowledge base:

1. The environment variable `AGENT_KB_DIR` (a folder of notes or docs), or
2. A "Knowledge base" section in `CLAUDE.md` / `AGENTS.md` naming a path or a skill to use for reading it.

If present, search it first (or delegate to the named skill) and cite the note you used. If absent, rely on the official One Identity documentation and say so. Never write to the knowledge base unless the user asks.

---

## First step: course or problem?

If the user's knowledge base contains a **One Identity Manager course syllabus**, ask first: *"Is this for the course or to solve something specific?"* Skip the question when the message already makes it clear, and skip it entirely if there is no syllabus.

### Course mode

1. Read the whole syllabus and follow any tutor instructions it contains (Socratic tutoring, step cycle, rules).
2. Ask for what the syllabus needs to start: student name, product version and current step (or "resume from progress tracking").
3. Teach each step **only** from the material the syllabus points to. Never invent menus, options or behaviour.
4. When the session ends, offer to update the syllabus progress section. Write only with the student's confirmation.

### Problem mode

Follow the **Working protocol** below.

---

## What One Identity Manager is

An **Identity Governance & Administration (IGA)** platform covering:

1. **Identity lifecycle**: joiners, movers, leavers
2. **Governance**: roles, policies, SoD (Separation of Duties), risk assessment
3. **Application governance**: provisioning and access governance for applications
4. **Compliance audit**: auditing and evidence for every event
5. **Self-service access**: end-user self-service portal
6. **Attestation / recertification**: access certification campaigns
7. **Privileged access governance**: integrates with Safeguard

### Architecture (classic 3-tier)

| Tier | Component | Role |
|------|-----------|------|
| **Data** | SQL Server / Azure SQL / Amazon RDS | Central database. Two logical parts: **payload** (identities, accounts, groups, approvals, attestation, compliance) and **metadata** (data model, scripts, system configuration, async queues) |
| **Logic** | Object Layer (VI.DB) | Object-oriented access to the database: entities, UnitOfWork, Insert/Update/Delete events |
| **Logic** | One Identity Manager Service (Job Server) | The only component allowed to change target systems. Processes Job Queue steps, synchronizes target systems, runs processes |
| **Logic** | Application Server | Database connection pool and business logic for clients |
| **Presentation** | Manager (.NET client) | Main administration front-end |
| **Presentation** | Web Portal | End-user self-service portal |
| **Presentation** | Web Designer | Web form and process design |
| **Presentation** | Administration Portal | Web-based administration |
| **Presentation** | Operations Support Web Portal | Operations |
| **Presentation** | Password Reset Portal | Password self-service |
| **Presentation** | API Server | Hosts the web portals and exposes the REST API |

### Key internal mechanisms

| Mechanism | Description |
|-----------|-------------|
| **DBQueue** | Inheritance recalculation tasks. Database triggers enqueue them; the DBQueue Processor handles them |
| **JobQueue** | Processing orders executed by the object layer (processes and steps) |
| **Jobgenerator** | Turns process templates into concrete processes in the Job Queue |
| **Processes** | Model business processes as steps with predecessor/successor relations |
| **Inheritance** | Properties inherited along hierarchies (departments, cost centers, locations, business roles) |

### Product tools

| Tool | Use |
|------|-----|
| **Manager** | Main administration (.NET client) |
| **Designer** | Schema, process and form design |
| **Configuration Wizard** | Initial installation setup |
| **Database Compiler** | Compiles the database (schema, processes) |
| **Database Transporter** | Moves changes between environments (dev → test → prod) |
| **Job Service Configuration** | Configures the One Identity Manager Service (Windows service or Linux daemon) |
| **Schema Extension** | Extends the schema |
| **License Meter** | License metering |
| **Software Loader** | Loads software and updates |
| **Server Installer** | Installs components on servers |
| **Data Import** | Data import |
| **Report Editor** | Report editing |
| **Crypto Configuration** | Encryption setup |
| **System Debugger** | System debugging |

### Editions

- **Standard Edition**: base identity management modules.
- **Full Edition**: all management modules (IT Shop & workflow, delegation, system and business roles, role mining, risk assessment, attestation, compliance, company policies, report subscriptions), Unified Namespace and Active Directory connectors.

---

## Working protocol

### 1. Get the installation context

Ask the user, unless it is already stated in the conversation:

- Product version (9.x, 10.0 LTS, …) and edition (Standard / Full)
- Database (SQL Server on-prem, Azure SQL, Amazon RDS)
- Topology: Job Server, Application Server, API Server; single server or distributed
- Front-ends in use (Manager, Web Portal, Web Designer, Administration Portal)
- Configured connectors (AD, CSV, SAP, custom)
- Server OS (Windows Server / Linux with Docker) and whether there is clustering / HA

### 2. Check the local knowledge base

See "Local knowledge base (optional)". A good knowledge base for this product usually has an index note mapping questions to notes; read the index first, then open only the note you need.

### 3. Official sources (web fallback)

- Documentation: `https://docs.oneidentity.com/bundle/one-identity-manager_*`
- Support / KB: `https://support.oneidentity.com/technical-documents/identity-manager/*`
- GitHub: `https://github.com/OneIdentity` (scripts, samples, SDK)
- One Identity Community forums

### 4. Answer

Base the answer on the knowledge base (if any) plus official documentation. If neither covers it, say so explicitly before relying on general experience.

### 5. Document (only if the user asks)

Write to the knowledge base only on explicit request, following its existing structure.

---

## IT Shop & workflows

### Concepts

| Concept | Description |
|---------|-------------|
| **IT Shop** | Service catalog where users request resources (roles, groups, applications) |
| **Shopping cart** | The user's request cart in the Web Portal |
| **Request** | Order for a catalog item; triggers an approval process |
| **Approval** | Approval steps defined in the approval policy/workflow (one or more approvers, escalation) |
| **Resource** | Requestable entity: role, group, application, account |
| **Role** | Bundle of resources assigned to identities (system roles, business roles) |
| **Assignment** | Link between identity and resource/role; direct or inherited |
| **Process** | Steps that carry out the assignment/removal (account creation, membership, …) |

### Typical request flow

1. The user requests a resource in the Web Portal (IT Shop).
2. A request is created with a status (pending, in approval, approved, denied).
3. The approval workflow runs (approvers per policy).
4. Approved → the assignment process is queued in the Job Queue.
5. The One Identity Manager Service runs the steps (create AD account, add to group, …).
6. The user sees the result in the portal; everything is audited.

### Workflow configuration

- Processes are modelled with **process templates** in the Designer.
- Each process has steps with predecessor/successor relations.
- Steps can include approvals, manual tasks, automated actions (scripts) and mail notifications.
- The **Jobgenerator** turns templates into concrete Job Queue processes.
- Monitor with **Job Queue Info**.

---

## Connectors

### Active Directory

1. **Prerequisites**: service account with read/write rights on the domain, network connectivity, resolvable DNS.
2. **Installation**: the connector is installed as a machine role on the Job Server.
3. **Manager setup**: create the target system with the domain data (FQDN, service account).
4. **Initial synchronization**: run the initial load (users, groups, OUs).
5. **Schema mapping**: verify AD attributes map correctly to the One Identity Manager schema.
6. **Provisioning processes**: verify create/modify/delete account processes are enabled.
7. **Test**: create a test identity and verify provisioning in AD.

### CSV

1. Define the **CSV structure** (columns, delimiter, encoding).
2. Configure the connector with the file path and column → attribute mapping.
3. Schedule the import (recurring job) or run it manually.
4. Verify processing in the Job Queue.

### Custom connectors

- Build custom connectors for applications without an official connector.
- Use the REST API or scripts inside provisioning processes.
- Reference: the integrations catalog at `https://www.oneidentity.com/one-identity-manager-integration/`.

---

## Daily health check

### 1. Services

| Service | Check |
|---------|-------|
| One Identity Manager Service (Job Server) | Running? Valid configuration? |
| Application Server | Responding? Connection pool OK? |
| API Server / IIS / web server | Portals responding? |
| SQL Server | Database reachable? Disk space? |

### 2. Processing queues

- **Job Queue**: stuck or failed processes? (Job Queue Info)
- **DBQueue**: pending recalculation tasks piling up?
- Failed processes: read the error and re-run when appropriate.

### 3. Target system synchronization

- Did connectors (AD, CSV, …) sync in the last cycle?
- Connection errors to target systems?

### 4. Logs

- One Identity Manager Service and Application Server logs.
- Look for recurring errors (authentication, DB connection, permissions).

### 5. Report

Summarize services OK/FAIL, queue state and errors found.

---

## Logs

| Component | Where to look |
|-----------|---------------|
| One Identity Manager Service | Service logs on the Job Server (Windows: Event Viewer / service log files; Linux: journal / daemon log files) |
| Application Server | Application logs on the app server |
| API Server / web | Web server logs (IIS / nginx) and application logs |
| SQL Server | SQL Server error log, deadlocks, blocking |
| Processes | Job Queue Info: status of each process/step |

---

## REST API and PowerShell

- The **API Server** exposes the One Identity Manager REST API. Reference: the *REST API Reference Guide* for your version on `support.oneidentity.com`.
- Typical uses: integrations, automation, querying identities and roles.
- PowerShell: One Identity provides PowerShell modules/cmdlets for querying identities, roles and requests and triggering processes. Check availability for the installed version.

---

## Troubleshooting: common issues

| Symptom | Likely cause | Action |
|---------|--------------|--------|
| Processes stuck in Job Queue | Service stopped, permissions, failing step | Read the step log, re-run, check the service |
| AD sync fails | Service account rights, connectivity, DNS | Verify credentials and connectivity |
| Web Portal not responding | API Server / web server down, DB unreachable | Check services and DB connection |
| Slow inheritance recalculation | DBQueue backlog, indexes | Monitor DBQueue, review DB performance |
| Permission error in Manager | User lacks admin permission groups | Verify the user's permission groups |

If the error is not in the knowledge base or official docs, search the exact message on support.oneidentity.com and the community forums.

---

## References

- Installation guide: `https://support.oneidentity.com/technical-documents/identity-manager/` (pick your version)
- Architecture overview: `https://docs.oneidentity.com/bundle/one-identity-manager_configuration_10.0/page/sources/config/architecture/oneimarchitectureoverview.html`
- Web Portal: `https://docs.oneidentity.com/bundle/one-identity-manager_web-portal_10.0/`
- GitHub: `https://github.com/OneIdentity`
