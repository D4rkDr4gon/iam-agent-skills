---
name: oneim-onelogin
description: >
  Use when administering OneLogin (cloud IAM by One Identity): SSO and the app catalog
  (SAML, OIDC, WS-Fed, form-based), MFA and adaptive authentication, cloud directory and
  connectors (AD, LDAP, Workday), roles, rules, policies, provisioning, Smart Hooks and the
  OAuth2 REST API. Organization-agnostic.
license: Apache-2.0
---

# oneim-onelogin

## Purpose

Administer, operate and troubleshoot a **OneLogin** organization (One Identity's cloud Identity and Access Management platform). Covers:

- Architecture (Unified Access Management)
- Single Sign-On and the application catalog
- Multi-Factor Authentication
- Cloud directory and connectors (AD, LDAP, Workday)
- Roles, rules and provisioning
- Smart Hooks
- REST API (OAuth2)
- Health checks and troubleshooting

**Out of scope**, use the sibling skills: `oneim-manager` (IGA), `oneim-safeguard` (PAM), `oneim-active-roles`, `oneim-password-manager`, `oneim-starling`.

> **Generic by design.** No organization-specific data. Always work from the tenant the user describes.

## Local knowledge base (optional)

Before answering from memory, check whether the user configured a knowledge base:

1. The environment variable `AGENT_KB_DIR` (a folder of notes or docs), or
2. A "Knowledge base" section in `CLAUDE.md` / `AGENTS.md` naming a path or a skill to use for reading it.

If present, search it first (or delegate to the named skill) and cite the note you used. If absent, rely on the official OneLogin documentation and say so. Never write to the knowledge base unless the user asks.

---

## What OneLogin is

A cloud **Unified Access Management (UAM)** platform combining:

1. **Single Sign-On**: one login for every application (catalog of thousands of pre-built apps)
2. **MFA**: OneLogin Protect (push), SMS, TOTP, WebAuthn/FIDO2
3. **Cloud Directory**: cloud source of truth for access management
4. **Directories and connectors**: sync with AD, LDAP, Workday and others
5. **Lifecycle management**: user provisioning, automated onboarding/offboarding
6. **Adaptive authentication**: risk scoring that detects anomalous logins and challenges with MFA
7. **OneLogin Desktop**: extends SSO to the OS login (macOS/Windows)

### Architecture

| Component | Role |
|------------|-----|
| **Cloud directory** | Central source of truth for identities and access |
| **SSO portal** | Single access point to all apps |
| **Connectors** | Real-time sync with on-prem and cloud directories (AD, LDAP, Workday) |
| **Apps** | Pre-built integrations (SAML, OIDC, WS-Fed, form-based) |
| **Policies** | Access rules (MFA, restrictions by location/role/privilege) |
| **Rules** | Automated app/role assignment from user attributes |
| **Smart Hooks** | Serverless functions intercepting authentication/provisioning events |
| **API** | Full REST API (OAuth2) for administration and integration |

### Regions

OneLogin runs in several regions (**us**, **eu**), which changes API and tenant URLs.

---

## Key concepts

### MFA factors

| Factor | Description |
|--------|-------------|
| **OneLogin Protect** | Mobile app with push notifications and OTP |
| **SMS** | OTP codes via SMS |
| **TOTP** | Time-based codes (Google Authenticator compatible) |
| **WebAuthn / FIDO2** | Security keys and biometrics |
| **Adaptive MFA** | Conditional challenges based on risk (location, device, behaviour) |

### Directories and connectors

- **Cloud Directory**: OneLogin's native directory
- **Active Directory / LDAP**: on-prem sync via the OneLogin directory connector agent
- **Workday**: identity sync from HR
- **Provisioning**: account provisioning/deprovisioning in connected apps

### Roles, rules and policies

- **Roles** group users to assign apps and policies.
- **Rules** automate role/app assignment from attributes (department, location, …).
- **Policies** control authentication (MFA required, sessions, restrictions).

### Smart Hooks

Serverless (Node.js) functions running on authentication, user provisioning and other events; custom logic without modifying the platform.

---

## Working protocol

### 1. Get the tenant context

Ask, unless already stated:

- Region (us / eu)
- Plan/edition
- Connected directories (Cloud Directory, AD, LDAP, Workday)
- Apps in use (SAML, OIDC, form-based)
- MFA configured? Which factors?
- Integrated with Starling or other One Identity products?

### 2. Check the local knowledge base

See "Local knowledge base (optional)".

### 3. Official sources (web fallback)

- Developers: `https://developers.onelogin.com/` (API, SDKs, tutorials)
- Support: `https://support.oneidentity.com/technical-documents/onelogin/*`

### 4. Answer

Base the answer on the knowledge base (if any) plus official documentation; say so when neither covers it.

### 5. Document (only if the user asks)

---

## REST API

### Authentication

- Every request needs an **OAuth2 Bearer token**, generated from a **client_id + client_secret** pair (API credentials).
- Endpoint: `POST /api/2/oauth2/token` (v1 for some resources).
- Use the minimum scope needed (e.g. `manage:users`, `manage:apps`; avoid `manage:all`).
- Never paste real client secrets into chat or notes; use environment variables.

### Main resources

| Resource | Operations |
|---------|-----------|
| **Users** | List, create, update, delete, bulk operations, reset password |
| **Apps** | List, create, update, get (backup/restore of app configuration) |
| **Roles** | List, create, assign users |
| **MFA** | Available factors, enroll, activate, verify |
| **Login** | Session login token, verify factor, create session |
| **Connectors** | List connectors |
| **Reports** | Data extraction for reporting |

SDKs exist for Ruby, Python, Node.js, Java, .NET, Go, PHP and PowerShell; Postman collections are available.

---

## Health check

1. **Platform**: service status (OneLogin status page); correct region for the tenant.
2. **Directories and sync**: is the AD/LDAP connector agent running and syncing? Recent sync errors? App provisioning working?
3. **Authentication**: successful logins; spike in failures? MFA working; users without an enrolled factor? Adaptive authentication alerts?
4. **Apps**: SAML/OIDC configuration errors? App certificates close to expiry?
5. **Report**: platform, sync, authentication, apps.

---

## Troubleshooting

| Symptom | Likely cause | Action |
|---------|---------------|--------|
| SSO fails for one app | Wrong SAML configuration (ACS, entity ID, certificate) | Compare app metadata and certificate |
| Users not syncing | Directory agent down, invalid credentials | Check the agent and its connection credentials |
| MFA unavailable | No enrolled factor, restrictive policy | Review policies and factor enrollment |
| API 401 | Expired token, insufficient scopes | Regenerate token, check API credential scopes |
| Login blocked | Adaptive authentication, location policies | Review risk events and policies |

---

## References

- Developers: `https://developers.onelogin.com/`
- API reference: `https://developers.onelogin.com/api-docs`
- MFA API: `https://developers.onelogin.com/api-docs/1/multi-factor-authentication/overview`
- Apps API: `https://developers.onelogin.com/api-docs/2/apps/overview`
