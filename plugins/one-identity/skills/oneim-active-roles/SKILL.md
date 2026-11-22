---
name: oneim-active-roles
description: >
  Use when administering One Identity Active Roles: Administration Service, Managed Units,
  Access Templates, Trustees, Policy Objects, approval and notification workflows, delegated
  administration of Active Directory / Exchange, reporting, health checks and
  troubleshooting. Installation-agnostic.
license: Apache-2.0
---

# oneim-active-roles

## Purpose

Administer, operate and troubleshoot **One Identity Active Roles** (delegated management of Active Directory). Covers:

- Architecture (presentation, service, data sources)
- Delegation: Managed Units, Access Templates, Trustees
- Policy Objects and policy enforcement
- Approval and notification workflows
- Reporting and auditing
- Health checks and troubleshooting

**Out of scope**, use the sibling skills: `oneim-manager` (IGA), `oneim-safeguard` (PAM), `oneim-onelogin`, `oneim-password-manager`, `oneim-starling`.

> **Generic by design.** No customer data or pre-built infrastructure. Always work from the installation the user describes.

## Local knowledge base (optional)

Before answering from memory, check whether the user configured a knowledge base:

1. The environment variable `AGENT_KB_DIR` (a folder of notes or docs), or
2. A "Knowledge base" section in `CLAUDE.md` / `AGENTS.md` naming a path or a skill to use for reading it.

If present, search it first (or delegate to the named skill) and cite the note you used. If absent, rely on the official One Identity documentation and say so. Never write to the knowledge base unless the user asks.

---

## What Active Roles is

A **delegated management and administration** solution for Active Directory (and other data sources such as Exchange). It provides:

1. **Granular delegation**: limited administrative rights without granting domain rights
2. **Policy enforcement**: business rules applied consistently to every operation
3. **Approval workflows**: operations that need approval before execution
4. **Automation**: home folder provisioning, group memberships, synchronization with other systems
5. **Auditing**: an audit trail of every attempted or completed operation

### Architecture

| Tier | Component | Role |
|------|-----------|------|
| **Presentation** | Active Roles Console (Windows) | Main administration UI |
| **Presentation** | Web Interface | Web UI for delegated administrative tasks |
| **Presentation** | Reporting | Automated reports on management activity |
| **Service** | Administration Service | Secure layer between administrators and data sources: policy enforcement, automation, business process integration. Can run as multiple instances (performance + fault tolerance) |
| **Service** | Administration Database | Stores Active Roles permissions, policies and configuration |
| **Data** | Active Directory / Exchange / others | Managed data sources |

### Operation flow

1. The administrator submits an operation (query or change) from the Console or Web Interface.
2. The **Administration Service** receives it (Request object).
3. **Access check**: does the user have sufficient rights?
4. **Pre-execution**: workflows (e.g. approvals) and pre-execution policies (validation, property generation).
5. **Execution**: the operation runs against the data source (e.g. create the user).
6. **Post-execution**: post-execution policies (home folder, memberships) and post workflows (notifications).

---

## Security and administration elements

Stored as objects in the Administration Database:

| Element | Description |
|---------|-------------|
| **Access Template** | Access level a Trustee has over objects/containers. A proxy mechanism to grant AD access without special rights |
| **Policy Object** | Collection of administrative policies (procedures + triggering events): validation, synchronization, batch tasks |
| **Managed Unit** | Administrative unit grouping AD objects under a delegation scope |

### Trustees

- AD users or groups with administrative rights in Active Roles.
- Assigned to Managed Units, objects or containers, together with the Access Templates that control what they can do.
- **Best practice**: delegate to groups, not individual users.

### Policy scope

A Policy Object can be linked to:
- Managed Units
- AD containers (OUs): applies to all objects in the container and sub-containers
- Individual leaf objects (e.g. a specific user)

> **Warning:** policies apply **even to Active Roles administrators**. Nobody bypasses them.

---

## Workflows

### Processing model

Every operation (Request object) goes through four phases:

```
Access check → Pre-execution → Execution → Post-execution
```

| Phase | Workflows | Policies |
|------|-----------|-----------|
| **Pre-execution** | Activities in the upper part of the diagram (e.g. **Approval**) | Pre-execution policies (validation, property generation, pre-event handlers) |
| **Post-execution** | Activities in the lower part (e.g. **Notification**) | Post-execution policies (provisioning, memberships, post-event handlers) |

### Matching and priority

- A workflow starts when the operation satisfies its **start conditions**.
- **Several workflows** can match one operation.
- Execution order: attribute `edsaWorkflowPriority` (default 500; lower value = higher priority; ties broken alphabetically by name).
- **If-Else activities** branch on operation data.

### Typical activities

- **Approval**: approvers allow or deny the operation
- **Notification**: completion emails
- **Script**: custom logic
- **If-Else**: conditional branching

---

## Working protocol

### 1. Get the installation context

Ask, unless already stated:

- Active Roles version (7.x, 8.0.x, 8.1.x, …)
- Number of Administration Service instances; HA?
- Managed data sources (AD, Exchange, others)
- Elements in use (Managed Units, Policy Objects, workflows)
- Starling integration (Starling Join, 2FA)?

### 2. Check the local knowledge base

See "Local knowledge base (optional)".

### 3. Official sources (web fallback)

- Documentation: `https://docs.oneidentity.com/bundle/active-roles_*`
- Support: `https://support.oneidentity.com/technical-documents/active-roles/*`
- GitHub: `https://github.com/OneIdentity`

### 4. Answer

Base the answer on the knowledge base (if any) plus official documentation; say so when neither covers it.

### 5. Document (only if the user asks)

---

## Health check

1. **Services**: Administration Service running on all instances? Administration Database reachable? Web Interface responding?
2. **Operations**: failed or stuck operations in approval workflows? Pending approvals piling up? Recurring errors in the audit trail?
3. **Integrations**: scripts in Policy Objects working? Starling integration (if any) active?
4. **Report**: services, operations, pending approvals.

---

## Troubleshooting

| Symptom | Likely cause | Action |
|---------|---------------|--------|
| Operation denied | Access check fails (Trustee lacks a sufficient Access Template) | Review Trustee assignments and Access Templates |
| Workflow does not start | Start conditions not met | Review workflow conditions |
| Approval request never arrives | Approvers without valid mailbox, mail not configured | Check recipients and notification settings |
| Policy not applied | Policy Object not linked to the right scope | Check the link (Managed Unit, OU, object) |
| Slow Administration Service | Unbalanced instances, slow database | Review instances and Administration Database performance |

If the error is not documented, search the exact message on support.oneidentity.com and the community.

---

## References

- Technical overview: `https://docs.oneidentity.com/bundle/active-roles_administration-guide_8.0.1/page/guides/administrationguide/technical-overview.htm`
- Workflow processing: `https://docs.oneidentity.com/bundle/active-roles_administration-guide_8.0.1/page/guides/administrationguide/workflow-processing-overview.htm`
- Policy Objects: `https://docs.oneidentity.com/bundle/active-roles_administration-guide_8.1.3/page/guides/administrationguide/how-policy-objects-work.htm`
- Service components: `https://docs.oneidentity.com/bundle/active-roles_feature-guide_8.1.3/page/guides/featureguide/service-components.htm`
