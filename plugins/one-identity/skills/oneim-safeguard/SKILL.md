---
name: oneim-safeguard
description: >
  Use when administering One Identity Safeguard (PAM): Safeguard for Privileged Passwords
  (SPP), Safeguard for Privileged Sessions (SPS) and Safeguard for Privileged Analytics
  (SPA). Assets, accounts, partitions, profiles, entitlements, access request policies,
  session recording, clustering/HA and the REST API. Also acts as a Socratic tutor when the
  user follows a Safeguard course syllabus kept in their knowledge base. Installation-agnostic.
license: Apache-2.0
---

# oneim-safeguard

## Purpose

Administer, operate and troubleshoot **One Identity Safeguard** (One Identity's PAM suite). Covers:

- Architecture: SPP, SPS, SPA
- Assets, accounts, partitions, profiles
- Entitlements and access request policies
- Privileged sessions (SPS)
- Clustering and high availability
- Health checks, troubleshooting and REST API

**Out of scope**, use the sibling skills: `oneim-manager` (IGA), `oneim-active-roles`, `oneim-onelogin`, `oneim-password-manager`, `oneim-starling`.

> **Generic by design.** No customer data or pre-built infrastructure. Always work from the installation the user describes.

## Local knowledge base (optional)

Before answering from memory, check whether the user configured a knowledge base:

1. The environment variable `AGENT_KB_DIR` (a folder of notes or docs), or
2. A "Knowledge base" section in `CLAUDE.md` / `AGENTS.md` naming a path or a skill to use for reading it.

If present, search it first (or delegate to the named skill) and cite the note you used. If absent, rely on the official One Identity documentation and say so. Never write to the knowledge base unless the user asks.

---

## First step: course or problem?

If the user's knowledge base contains a **Safeguard course syllabus**, ask first: *"Is this for the Safeguard course or to solve something specific?"* Skip the question when the message already makes it clear, and skip it entirely if there is no syllabus.

### Course mode

1. Read the whole syllabus and follow any tutor instructions it contains (Socratic tutoring, step cycle, rules).
2. Ask for what the syllabus needs to start: student name, Safeguard version and current step (or "resume from progress tracking").
3. Teach each step **only** from the material the syllabus points to (including any review questions or demo script it references). Never invent menus, options or behaviour.
4. When the session ends, offer to update the progress section. Write only with the student's confirmation.

### Problem mode

Follow the **Working protocol** below.

---

## What Safeguard is

One Identity's **Privileged Access Management (PAM)** solution. Three products usable together or separately:

| Product | Acronym | Function |
|----------|-------|---------|
| **Safeguard for Privileged Passwords** | SPP | Vault for passwords, SSH keys and secrets. Rotation, credential check/change, access workflows |
| **Safeguard for Privileged Sessions** | SPS | Privileged session proxy: intercepts, controls, records and analyzes sessions (RDP, SSH, Telnet, …) |
| **Safeguard for Privileged Analytics** | SPA | Machine-learning behaviour analytics for privileged users; detects and ranks anomalies by risk |

### Deployment model

- **SPP**: hardened hardware appliance or virtual appliance; also available as a hosted/On Demand offering.
- **SPS**: appliance or virtual appliance acting as a network proxy (transparent or non-transparent mode).
- **SPA**: consumes SPS data for behaviour analytics.

### SPP + SPS operating modes

| Mode | Flow |
|------|-------|
| **SPP-initiated** | The user requests access in the SPP portal; once approved, connects to the target through SPS |
| **SPS-initiated** | The user connects directly to the target; SPS intercepts the traffic and fetches credentials from SPP |

---

## SPP concepts

| Entity | Description |
|---------|-------------|
| **Asset** | Managed computer, server, network device, directory or application. An asset belongs to one partition at a time |
| **Account** | User or service account on an asset. An account belongs to one asset |
| **Asset Group** | Set of assets that can be added to an entitlement's scope |
| **Partition** | Delegation container for password/SSH key management (check/change). Segregates assets by owner (SoD). Creating a partition creates a default profile |
| **Profile** | Rules and schedules governing a partition's assets/accounts (check frequency, change policy). An account is governed by one profile (explicit > implicit) |
| **Entitlement** | Set of access request policies restricting resources, typically by job role |
| **Access Request Policy** | Access type (password, SSH key, session), conditions (approver count, time windows, ticketing, reason codes) and scope (accounts, account groups, assets, asset groups) |
| **User / User Group** | People using Safeguard: administrative roles (Asset Admin, Security Policy Admin, User Admin, Auditor) or standard users (request/approve) |
| **Discovery Job** | Finds unmanaged assets and accounts to bring them under management |

### Administrator hierarchy (initial setup)

1. **Authorizer Administrator**: first admin; creates the other administrators
2. **Appliance Administrator**: appliance configuration (network, backups, clustering)
3. **User Administrator**: users and groups
4. **Asset Administrator**: managed systems
5. **Security Policy Administrator**: access request policies and entitlements

> **Best practice:** follow SoD; Asset, Security Policy, User Administrator and Auditor should be different people.

### Typical access flow

1. A user (or an integration via API) requests a credential or a session.
2. The request goes through the access request policy (approvals, conditions).
3. Approved → credential checkout or session connection (proxied and recorded by SPS).
4. Check-in when done; the policy may require review or credential change.

---

## SPS concepts

- **Protocol proxy**: SSH, Telnet, RDP, HTTP(S), ICA, VNC
- **Traffic control**: application-level inspection; can reject protocol-violating traffic
- **Recording**: keystrokes, mouse, windows; encrypted, timestamped, cryptographically signed audit trails
- **Search**: indexed events; video-like playback
- **Session policies**: predefined patterns (risky commands, suspicious window titles) → log, alert or terminate the session
- **Transparent mode**: acts as an invisible router; users keep their workflow

---

## Clustering and HA

### SPP

- Cluster of **3 or 5 appliances** (join); shared configuration and full replication.
- Scalability, HA and disaster recovery in one architecture; keeps working when some appliances fail.

### SPS

- **HA pair**: primary + hot-spare secondary that replicates everything and takes over on failure.
- **Scalability cluster**: multiple nodes with different roles, managed from a single pane of glass.
- HA and scalability are configured independently.

### Interoperation

An SPP cluster can join one or more SPS clusters (SPP-SPS join), combining password rotation and session recording for the same accounts.

---

## Working protocol

### 1. Get the installation context

Ask, unless already stated:

- Products in use (SPP, SPS, SPA) and versions (e.g. 8.0 LTS)
- Physical, virtual or hosted appliances
- Clustering (3/5-node SPP, SPS HA pair)
- SPP-SPS join? Integration with One Identity Manager (privileged account governance)?
- Authentication: local, AD, SAML 2.0, RADIUS 2FA

### 2. Check the local knowledge base

See "Local knowledge base (optional)".

### 3. Official sources (web fallback)

- Documentation: `https://docs.oneidentity.com/bundle/safeguard-for-privileged-passwords_*` and `safeguard-for-privileged-sessions_*`
- Support: `https://support.oneidentity.com/technical-documents/safeguard-*`
- GitHub: `https://github.com/OneIdentity` (SDKs such as safeguard-ps / PySafeguard, integration scripts)

### 4. Answer

Base the answer on the knowledge base (if any) plus official documentation; say so when neither covers it.

### 5. Document (only if the user asks)

---

## Health check

1. **Appliances**: SPP/SPS reachable? Cluster healthy (all nodes up, replication OK)? Recent backups?
2. **Credential management**: last check/change runs successful? Accounts with failed checks? (Common Windows cause: UAC "Run all administrators in Admin Approval Mode" must be disabled for local resets.) Discovery jobs OK?
3. **Sessions (SPS)**: protocol proxies working? Sessions recorded correctly? Risky-pattern alerts?
4. **Access**: requests flowing normally? Pending approvals piling up?
5. **Report**: appliances, cluster, password checks, sessions.

---

## REST API

- Every function is exposed through a REST API; typical uses are integrations, request automation and reporting.
- Authentication with tokens (username/password or certificate login).
- Reference: the API documentation for your SPP version on `support.oneidentity.com`, plus the SDKs on GitHub.

---

## Troubleshooting

| Symptom | Likely cause | Action |
|---------|---------------|--------|
| Password check/change fails on Windows | UAC "Admin Approval Mode" enabled | Disable that local security policy |
| Cannot connect to SPP | Appliance down, network, certificates | Check connectivity and appliance status |
| Sessions not recorded | Traffic not routed through SPS, recording policy | Check traffic routing and SPS configuration |
| Degraded cluster | Node down, replication failure | Check node status and inter-appliance network |
| Access request denied | Policy without approvers, unmet conditions | Review the access request policy and its conditions |

---

## References

- SPP Administration Guide: `https://support.oneidentity.com/technical-documents/one-identity-safeguard-for-privileged-passwords/`
- SPS: `https://support.oneidentity.com/technical-documents/safeguard-for-privileged-sessions/`
- GitHub: `https://github.com/OneIdentity`
