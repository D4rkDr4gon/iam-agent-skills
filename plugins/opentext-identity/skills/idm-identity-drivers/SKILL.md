---
name: idm-identity-drivers
description: >
  Use when working with OpenText (NetIQ) Identity Manager drivers: Active Directory, LDAP,
  REST, JDBC and other connectors; Remote Loader setup; Publisher/Subscriber channels,
  policy sets, DirXML Script, XPath nouns, filters, schema mapping, shim configuration,
  driver health, traces and dxcmd. Linux and Windows.
license: Apache-2.0
---

# idm-identity-drivers

## Purpose

Design, configure and troubleshoot **Identity Manager drivers**: the connectors that synchronize the Identity Vault (eDirectory) with connected systems.

**Out of scope**: server/service operations (`idm-identity-servers`), workflow forms (`idm-workflow-forms`), certificates in depth (`enterprise-certificates`).

> **Generic by design.** No customer data. Work from the driver set, driver configuration and policies the user shows you.

## Local knowledge base (optional)

Before answering from memory, check whether the user configured a knowledge base:

1. The environment variable `AGENT_KB_DIR` (a folder of notes or docs), or
2. A "Knowledge base" section in `CLAUDE.md` / `AGENTS.md` naming a path or a skill to use for reading it.

If present, search it first (or delegate to the named skill) and cite the note you used. If absent, rely on official OpenText documentation and say so. Never write to the knowledge base unless the user asks.

---

## Driver architecture

```
Identity Vault (eDirectory) ⇄ Engine ⇄ Driver policies ⇄ Shim ⇄ Connected system
                                                  (local or via Remote Loader)
```

| Concept | Description |
|---|---|
| **Driver set** | Container of drivers bound to one or more servers |
| **Driver** | Configuration + policies + shim for one connected system |
| **Shim** | The connector binary (Java/.NET/native) that talks to the connected system |
| **Subscriber channel** | Vault → connected system (events from eDirectory) |
| **Publisher channel** | Connected system → vault (events from the application) |
| **Filter** | Which classes/attributes each channel synchronizes, notifies or ignores |
| **Schema mapping** | Maps vault classes/attributes to application classes/attributes |
| **Association** | Link between a vault object and its connected-system object |
| **GCVs** | Global Configuration Values: driver-level settings referenced from policies |
| **Driver parameters / named passwords** | Shim settings and stored secrets |

### Policy sets (processing order)

| Channel | Policies |
|---|---|
| **Subscriber** | Event transformation → Matching → Creation → Placement → Command transformation → Schema mapping → Output transformation |
| **Publisher** | Input transformation → Schema mapping → Event transformation → Matching → Creation → Placement → Command transformation |

Policies are written in **DirXML Script** (rules with conditions and actions) or XSLT, using **XPath** and **nouns** (`attr`, `op-attr`, `src-attr`, `dest-attr`, `global-config-value`, `named-password`, `association`, `xpath`, …) to read event data.

### Common driver types

| Driver | Notes |
|---|---|
| **Active Directory** | Usually runs through a Remote Loader on a Windows domain member; password sync via the Password Filter on DCs |
| **LDAP** | Generic LDAP directories (OpenLDAP, other eDirectory trees, …) |
| **REST** | Generic REST driver: authentication (anonymous, basic, OAuth 2.0), HTTP methods, XML/JSON payloads mapped in policies |
| **JDBC** | Databases (direct tables/views or triggered event logs) |
| **Delimited Text** | File-based integration (CSV) |
| **SOAP / Entitlement / Bidirectional eDirectory / Loopback / Null** | Other built-in drivers |

---

## Remote Loader

- Hosts a driver shim on a machine other than the IDM engine server (e.g. AD shim on Windows).
- Engine ↔ Remote Loader connection is encrypted with TLS; both sides share the Remote Loader and driver object passwords.
- Defaults: connection port **8090**, HTTP control port **8000**; many deployments use custom ports per instance (one pair per driver instance).
- Configure in the Remote Loader console (Windows) or `dirxml_jremote` / `rdxml` configuration files (Linux), and set `hostname=… port=…` and the TLS settings in the driver's Remote Loader parameters.
- Firewall: open the connection port from the engine to the Remote Loader host, plus the connected system's ports (e.g. LDAPS 636 to DCs).

---

## Working protocol

### 1. Get context

- IDM and driver versions; driver type and shim (local or Remote Loader)
- Channel and direction of the problem (Subscriber / Publisher)
- What object/attribute/event is affected; expected vs actual result
- A **driver trace** excerpt covering the event (see below)

### 2. Read the trace

Set the driver trace level (driver properties → *Trace*; level 3 is a good default for troubleshooting, up to 5 for detail) and a trace file with size limit. Follow the event through each policy and look for:

- `status level="error|warning|retry"` and the message
- Which policy vetoed or transformed the event (`<veto>`, rule results)
- Matching results (found / not found / multiple)
- Shim errors returned by the connected system

Turn trace back down afterwards; high trace levels hurt performance.

### 3. Check sources

Knowledge base (if any), then the official driver implementation guide for that driver, then OpenText Community / KB.

### 4. Answer

Give the policy change as DirXML Script (and say which policy set and position), or the exact driver/shim parameter to change. Recommend testing in a non-production driver or with the Designer simulator first.

### 5. Document (only if the user asks)

---

## dxcmd quick reference

```bash
# interactive menu (prompted for password)
/opt/novell/eDirectory/bin/dxcmd -host <edir-host> -user <admin-dn>
# common non-interactive operations
dxcmd -user <admin-dn> -getstate   <driver-dn>
dxcmd -user <admin-dn> -start      <driver-dn>
dxcmd -user <admin-dn> -stop       <driver-dn>
dxcmd -user <admin-dn> -migrateapp <driver-dn> <xml-file>
```

Avoid `-password` on the command line; let it prompt.

---

## Troubleshooting

| Symptom | Likely cause | Action |
|---|---|---|
| Driver will not start | Remote Loader unreachable, wrong passwords, certificate/TLS mismatch | Check RL service, port, passwords on both sides, trusted root |
| Events not reaching the app | Filter set to ignore, event vetoed in a policy | Check filter and trace for the veto |
| Duplicate objects | Matching policy too weak | Strengthen matching (unique keys), add association handling |
| Objects created in wrong container | Placement policy | Review placement rules and GCVs |
| Password sync fails (AD) | Password Filter missing on some DC, PasswordSync config | Verify filter on all DCs and the password sync settings |
| Publisher not picking up changes | Polling interval, change log / event table, permissions of the shim account | Check shim parameters and account rights |

---

## References

- [Identity Manager driver documentation](https://www.netiq.com/documentation/identity-manager-410-drivers/) (implementation guide per driver)
- [Policies in Designer / DirXML Script reference](https://www.netiq.com/documentation/identity-manager-410/) (Policy reference)
- [OpenText Community: Identity](https://community.opentext.com/cybersec/identity/)
