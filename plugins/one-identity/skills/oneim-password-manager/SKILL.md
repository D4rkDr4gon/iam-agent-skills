---
name: oneim-password-manager
description: >
  Use when administering One Identity Password Manager: Password Manager Service,
  Administration / Self-Service / Helpdesk Sites, Management Policies, Q&A profiles,
  Password Policy Manager, Secure Password Extension, realms, FIDO2, cross-platform password
  sync and troubleshooting. Installation-agnostic; on-prem Windows product.
license: Apache-2.0
---

# oneim-password-manager

## Purpose

Administer, operate and troubleshoot **One Identity Password Manager** (password self-service for Active Directory and connected systems). Covers:

- Architecture and components
- Management Policies and password policies
- Administration, Self-Service and Helpdesk Sites
- Self-service workflows (registration, reset, unlock, Q&A)
- Password Policy Manager and Secure Password Extension
- Realms and multi-instance deployments
- Health checks and troubleshooting

**Out of scope**, use the sibling skills: `oneim-manager` (IGA), `oneim-safeguard` (PAM), `oneim-active-roles`, `oneim-onelogin`, `oneim-starling`.

> **Generic by design.** No customer data or pre-built infrastructure. Always work from the installation the user describes.

## Local knowledge base (optional)

Before answering from memory, check whether the user configured a knowledge base:

1. The environment variable `AGENT_KB_DIR` (a folder of notes or docs), or
2. A "Knowledge base" section in `CLAUDE.md` / `AGENTS.md` naming a path or a skill to use for reading it.

If present, search it first (or delegate to the named skill) and cite the note you used. If absent, rely on the official One Identity documentation and say so. Never write to the knowledge base unless the user asks.

---

## What Password Manager is

A web-based **self-service password management** solution for Active Directory and connected systems:

1. **Self-service**: users register, change and reset passwords without helpdesk involvement
2. **Delegated helpdesk**: operators reset passwords, unlock accounts, issue temporary passcodes
3. **Password policies**: strong policy enforcement in the domain
4. **Q&A authentication**: secret questions to verify identity
5. **Cross-platform sync**: password changes propagated to connected systems (Quick Connect Sync Engine / Redistributable Secret Management Service)
6. **FIDO2**: security key management

### Components

| Component | Role |
|------------|-----|
| **Password Manager Service** | Core service processing password operations |
| **Workflow Service** | Runs site workflows |
| **Administration Site** | Configuration: site settings, policies, workflows |
| **Self-Service Site** | End-user self-service portal |
| **Helpdesk Site** | Helpdesk operator portal (reset, unlock, passcodes, Q&A) |
| **Password Policy Manager** | Domain password policy enforcement (install on every x64 DC) |
| **Secure Password Extension** | Self-Service Site access from the Windows logon screen + registration notifications |
| **Offline Password Reset** | Password reset without intranet connectivity |
| **SQL Server database + SSRS** | Database and reporting |
| **Secure Token Server** | Secure token issuing |
| **Redistributable Secret Management Service** | Password sync across connected systems |
| **Quick Connect Sync Engine** | Sync engine for cross-platform password changes |
| **Migration Wizard** | Profile update when re-initializing the instance |

### Sites

| Site | Audience | Functions |
|------|-----------|-----------|
| **Administration Site** | Administrators | Site settings, policies, workflows |
| **Self-Service Site** | End users | Register, manage profile, edit Q&A, reset/change password, unlock/enable account, subscribe to notifications, BitLocker recovery key |
| **Helpdesk Site** | Helpdesk operators | Reset password, unlock account, assign passcode, unlock Q&A profile, enforce Q&A update, restart failed workflow |

> The **legacy Self-Service site** is deprecated since Password Manager 5.14.0; use the new Self-Service Site.

---

## Management Policies

- Define who can do what (user scope, enabled workflows).
- Can be added or cloned.
- Configure site access, self-service workflows and password policies.
- Each policy has a **user scope** and a **helpdesk scope**.

### Accounts used by Password Manager

| Account | Use |
|--------|-----|
| **Service account** | Main service |
| **Application pool identity** | IIS application pool |
| **Domain management account** | Management rights in the domain |
| **Password policy account** | Applies password policies |
| **Quick Connect account** | Cross-platform sync |

---

## Realms and deployments

- **Realm**: one or more instances sharing configuration (scopes, Management Policies, workflows, settings).
- Add a member by installing a new instance and choosing **"A replica of an existing instance"** during initialization.
- **Realm affinity**: forces Secure Password Extension to use only instances of a given realm.
- **FailSafe**: continuity on failures.

| Deployment | Description |
|------|-------------|
| **Simple** | One instance with all components |
| **Standalone sites** | Self-Service and Helpdesk Sites on separate servers |
| **Realm** | Several instances sharing configuration |
| **Multiple realms** | Several realms for different environments/segments |

---

## Working protocol

### 1. Get the installation context

Ask, unless already stated:

- Version (5.14.x, 5.15, …)
- Installed components (Service, sites, Password Policy Manager, Secure Password Extension, Offline Password Reset)
- Simple, standalone sites or realm deployment?
- Existing Management Policies
- Quick Connect / Redistributable Secret Management Service in use?
- FIDO2 in use?

### 2. Check the local knowledge base

See "Local knowledge base (optional)".

### 3. Official sources (web fallback)

- Documentation: `https://docs.oneidentity.com/bundle/password-manager_admin-guide_*`
- Support: `https://support.oneidentity.com/technical-documents/password-manager/*`

### 4. Answer

Base the answer on the knowledge base (if any) plus official documentation; say so when neither covers it.

### 5. Document (only if the user asks)

---

## Health check

1. **Services**: Password Manager Service and Workflow Service running? SQL Server reachable, SSRS responding? Sites responding?
2. **Workflows**: failed or stuck workflows? Successful resets in the last period? Q&A authentication errors?
3. **Domain**: Password Policy Manager active on the DCs? Secure Password Extension deployed and finding the Self-Service Site (service connection points)? Service account rights valid?
4. **Sync**: password changes replicated to connected systems? Sync errors?
5. **Report**: services, workflows, domain, sync.

---

## Troubleshooting

| Symptom | Likely cause | Action |
|---------|---------------|--------|
| Self-Service Site not found from logon screen | Service connection points missing or wrong | Check SCPs in AD; manual URL override if needed |
| Password reset fails | Service account rights, domain policy | Check credentials and Management Policy |
| Workflow stuck | Workflow Service stopped, failing step | Check workflow logs, restart if appropriate |
| Q&A unavailable | User has no registered Q&A profile | Check registration; helpdesk can unlock the Q&A profile |
| Password Policy Manager not enforcing | Not installed on every x64 DC | Install on all DCs |
| Cross-platform sync fails | Quick Connect / Secret Management Service down | Check the service and connected accounts |

---

## References

- Architecture: `https://docs.oneidentity.com/bundle/password-manager_admin-guide_5.15/page/guides/adminguide/pm-architecture-cover.htm`
- Components: `https://docs.oneidentity.com/bundle/password-manager_admin-guide_5.14.4/page/guides/adminguide/pm-components.htm`
- Administration Guide: `https://support.oneidentity.com/technical-documents/password-manager/`
