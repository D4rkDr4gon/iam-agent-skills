---
name: oneim-starling
description: >
  Use when administering One Identity Starling (cloud platform): organizations and
  subscriptions, Starling Connect (SCIM cloud connectors), Starling Join, Starling
  Two-Factor Authentication, Identity Analytics & Risk Intelligence, the status page and
  integration with other One Identity products. Organization-agnostic.
license: Apache-2.0
---

# oneim-starling

## Purpose

Administer, operate and troubleshoot **One Identity Starling** (One Identity's cloud services). Covers:

- Platform: organizations, accounts, services
- Starling Connect (cloud connectors, SCIM)
- Starling Join (AD and products)
- Starling Two-Factor Authentication
- Identity Analytics & Risk Intelligence
- Integration with One Identity products (Active Roles, One Identity Manager, OneLogin, …)
- Status page and troubleshooting

**Out of scope**, use the sibling skills: `oneim-manager` (IGA), `oneim-safeguard` (PAM), `oneim-active-roles`, `oneim-onelogin`, `oneim-password-manager`.

> **Generic by design.** No organization-specific data. Always work from the organization the user describes.

## Local knowledge base (optional)

Before answering from memory, check whether the user configured a knowledge base:

1. The environment variable `AGENT_KB_DIR` (a folder of notes or docs), or
2. A "Knowledge base" section in `CLAUDE.md` / `AGENTS.md` naming a path or a skill to use for reading it.

If present, search it first (or delegate to the named skill) and cite the note you used. If absent, rely on the official One Identity documentation and say so. Never write to the knowledge base unless the user asks.

---

## What Starling is

One Identity's **SaaS platform** delivering One Identity capabilities as cloud services. Administrators use the Starling site to:

1. Create an **organization**
2. Register accounts and add **services** to the organization
3. Securely access the subscribed services

### Sites

| Site | URL | Use |
|-------|-----|-----|
| **Starling Platform** | `https://www.cloud.oneidentity.com/` | Main portal: organizations, services, subscriptions |
| **Status page** | `https://status.cloud.oneidentity.com/` | Operational status per service (check before opening a support case) |

### Platform authentication

| Type | Description |
|------|-------------|
| **General accounts** | Accounts authenticating against Starling itself (create organization, log in) |
| **Work accounts** | Accounts backed by a configured Microsoft Entra ID (Azure AD) tenant; Starling redirects there to authenticate |

> Available data centers (US or EU) depend on the subscription; some services exist only in some regions.

---

## Services

### Starling Connect

- **Cloud identity governance**: extends IGA (One Identity Manager / AD / Entra ID) to cloud applications.
- Syncs users, groups and containers based on the **SCIM schema**.
- Onboards cloud apps without custom code; real-time reporting of resources and user access.
- **Connectors**: catalog of cloud app connectors, configured and activated from the console.
- **SCIM credentials**: used by the connecting systems.

### Starling Join

- Connects on-prem products/AD to Starling services.
- Lets products such as Active Roles use Starling services (2FA, Identity Analytics).
- Configured with the product's Starling wizard (e.g. Active Roles Configuration Center → Starling → Configure).

### Starling Two-Factor Authentication

- Cloud MFA integrated with One Identity products (Active Roles and others).
- Enabled/disabled from the integrated product (e.g. its Starling tab).

### Identity Analytics & Risk Intelligence

- Identity and risk analytics from connected product data; requires the product to be joined to Starling.

### Others (depending on subscription)

Hosted variants (e.g. Starling Connect for Active Roles), On Demand services (e.g. Safeguard On Demand). The catalog depends on the organization's subscription.

---

## Working protocol

### 1. Get the organization context

Ask, unless already stated:

- Subscribed services (Connect, Join, 2FA, Identity Analytics, others)
- Integrated One Identity products
- US or EU data center
- General accounts or work accounts (Entra ID)
- Active Starling Connect connectors

### 2. Check the local knowledge base

See "Local knowledge base (optional)".

### 3. Official sources (web fallback)

- Status: `https://status.cloud.oneidentity.com/`
- User guide: `https://support.oneidentity.com/technical-documents/one-identity-starling/hosted/user-guide`
- Starling Connect: `https://support.oneidentity.com/technical-documents/starling-connect/`

### 4. Answer

Base the answer on the knowledge base (if any) plus official documentation; say so when neither covers it.

### 5. Document (only if the user asks)

---

## Health check

1. **Platform**: status page clean? Organization active, subscriptions valid?
2. **Connections**: integrated products still joined? Starling Connect active and connectors syncing? SCIM credentials valid?
3. **Services**: 2FA working in integrated products? Identity Analytics receiving data?
4. **Report**: platform, connections, services.

---

## Troubleshooting

| Symptom | Likely cause | Action |
|---------|---------------|--------|
| Cannot reach a service | Platform incident, expired subscription | Check the status page and subscription |
| Join fails | Invalid Starling credentials, wrong organization | Verify credentials and organization; re-run the wizard |
| Starling Connect not syncing | Inactive connector, invalid SCIM credentials | Check the connector and credentials |
| 2FA not enforced | Starling 2FA disabled in the integrated product | Enable it from the product |
| Work account login fails | Entra ID tenant not configured or not synced | Check the tenant configuration |

---

## References

- Starling Platform: `https://www.cloud.oneidentity.com/`
- User guide: `https://support.oneidentity.com/technical-documents/one-identity-starling/hosted/user-guide`
- Starling Connect: `https://www.oneidentity.com/products/starling-connect/`
- Starling Connect for Active Roles: `https://support.oneidentity.com/technical-documents/starling-connect/hosted/active-roles-administration-guide/`
