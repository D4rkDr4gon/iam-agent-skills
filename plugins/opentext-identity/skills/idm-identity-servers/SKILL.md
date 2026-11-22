---
name: idm-identity-servers
description: >
  Use when operating or troubleshooting OpenText (NetIQ) Identity Manager servers:
  eDirectory (Identity Vault), Identity Manager Engine, Identity Applications (Tomcat),
  Remote Loader, OSP, SSPR, Identity Console, iManager, ActiveMQ, NGINX, Identity Reporting.
  Health checks, log locations and analysis, service management, configuration files.
  Linux and Windows. Does not cover installation.
license: Apache-2.0
---

# idm-identity-servers

## Purpose

Maintain, operate and troubleshoot the servers of the **OpenText Identity Manager (IDM)** stack:

- General architecture and components
- Log locations per service
- eDirectory error research
- Health checks and component diagnostics
- Collecting the environment's architecture before working

**Out of scope**: installation; drivers (`idm-identity-drivers`); workflow forms (`idm-workflow-forms`); Access Manager (`nam-access-manager`); structured health-check reports (`iam-health-check`).

> **Generic by design.** No customer data. Always work from the environment the user describes. Paths below are product defaults; confirm them on the actual servers.

## Local knowledge base (optional)

Before answering from memory, check whether the user configured a knowledge base:

1. The environment variable `AGENT_KB_DIR` (a folder of notes or docs), or
2. A "Knowledge base" section in `CLAUDE.md` / `AGENTS.md` naming a path or a skill to use for reading it.

If present, search it first (or delegate to the named skill) and cite the note you used. Known-error notes are especially valuable here. If absent, rely on official OpenText documentation and say so. Never write to the knowledge base unless the user asks.

---

## What IDM is

**OpenText Identity Manager** (formerly NetIQ / Micro Focus / Novell Identity Manager) is an identity management platform providing:

1. **Identity synchronization** across systems (AD, LDAP, HR, databases, …)
2. **Automated provisioning** driven by business rules
3. **Approval workflows** for resources, roles and access
4. **Roles and certifications**
5. **Self-service**: password management (SSPR), profile data, requests
6. **Reporting**: identity auditing and reports

### Components

| Component | Role | Technology |
|-----------|------|-----------------|
| **eDirectory (Identity Vault)** | Underlying LDAP directory: identities, configuration, drivers, roles | eDirectory |
| **Identity Manager Engine** | Provisioning engine: processes vault events and applies policies through drivers | Native Linux/Windows |
| **Identity Applications** | User App, Dashboard, Workflows, Role Service: the product web UI | Apache Tomcat + PostgreSQL |
| **OSP (One SSO Provider)** | SSO provider for Identity Applications: sessions and authentication | Java component in Tomcat |
| **SSPR** | Self-service password reset | Standalone web app |
| **Remote Loader** | Hosts drivers that run outside the IDM server (e.g. AD on Windows) | .NET / Java |
| **Fan-Out Agent** | Distributes events to multiple Remote Loaders | Native |
| **Identity Console** | Modern web administration console (iManager replacement) | Web (HTML5) |
| **iManager** | Legacy admin console for eDirectory and IDM | Web (Java) |
| **Designer** | Design IDE: drivers, workflows, forms, policies | Eclipse-based client |
| **Identity Reporting** | Reports and auditing | Tomcat + PostgreSQL |
| **Sentinel Log Management for IGA** | Event auditing | Standalone server |
| **ActiveMQ** | Async messaging between IDM components | Apache ActiveMQ |
| **NGINX** | Reverse proxy for Identity Applications | NGINX |

### Editions

- **Standard**: Engine + eDirectory + Identity Console + SSPR + Reporting
- **Advanced**: Standard + Identity Applications (User App, Dashboard, Workflows, Roles)

---

## Working protocol

### 1. Get the environment context

Ask, unless already stated:

- IDM version (4.8, 4.10, CE 24.x, …) and eDirectory version (9.2, 9.3, 24.x)
- Advanced or Standard Edition
- Installed components (Engine, Identity Apps, SSPR, Reporting, …)
- Single server or distributed; cluster (HA) or not
- OS (SLES, RHEL, Windows); Remote Loaders on Windows?
- Relevant URLs / FQDNs / ports

### 2. Research eDirectory errors

1. Check the local knowledge base for the error code or message.
2. Search the web for the exact code/message, OpenText KB articles (former TIDs) and the OpenText Community (`https://community.opentext.com`).

### 3. Read the logs

Identify the failing component and read its log (tables below).

### 4. Answer

Base the answer on the knowledge base (if any) plus official documentation; say so when neither covers it.

### 5. Document (only if the user asks)

---

## Log locations (Linux defaults)

### Identity Engine + eDirectory

| Log | Path | Purpose |
|-----|------|-----------|
| ndsd.log | `/var/opt/novell/eDirectory/log/ndsd.log` | Main eDirectory log |
| ndstrace.log | `/var/opt/novell/eDirectory/log/ndstrace.log` | eDirectory trace (debug) |
| DHost errors | `/var/opt/novell/eDirectory/log/DHostError.log` | DHost errors |
| Driver traces | Path set per driver (trace file in driver settings) | Individual driver traces |

### Identity Applications (Tomcat)

| Log | Path | Purpose |
|-----|------|-----------|
| catalina.out | `/opt/netiq/idm/apps/tomcat/logs/catalina.out` | Main Tomcat log |
| localhost.log | `/opt/netiq/idm/apps/tomcat/logs/localhost.*.log` | Tomcat/client interactions |
| idapps.out | `/opt/netiq/idm/apps/tomcat/logs/idapps.out` | Identity Applications (User App) |
| osp-idm-*.log | `/opt/netiq/idm/apps/tomcat/logs/osp-idm-*.log` | OSP (SSO) |
| localhost_access_log | `/opt/netiq/idm/apps/tomcat/logs/localhost_access_log.*.txt` | HTTP access log |
| workflow.log | `/opt/netiq/idm/apps/tomcat/logs/workflow.log` | Workflow engine |

### Other components

| Component | Path |
|-----|------|
| SSPR | `/opt/netiq/idm/apps/sspr/sspr_data/logs/SSPR.log` |
| Identity Reporting | `/var/opt/netiq/idm/log/` |
| Remote Loader (Linux) | `/opt/novell/eDirectory/lib/nds-modules/dirxml/RemoteLoader/logs/` (or the trace file set in the instance config) |
| Remote Loader (Windows) | `C:\Program Files\Novell\RemoteLoader\` (trace file set per instance) |
| ActiveMQ | `/opt/netiq/idm/apps/activemq/data/activemq.log` |
| NGINX | `/opt/netiq/idm/apps/sites/logs/access.log`, `error.log` |
| Identity Console | `/opt/netiq/idconsole/logs/` |
| iManager | `/opt/novell/iManager/tomcat/logs/catalina.out`, `/var/opt/novell/iManager/log/` |

---

## systemd services (Linux)

| Service | Component |
|----------|-----------|
| `ndsd` | eDirectory (+ Engine) |
| `netiq-tomcat` | Identity Applications (Tomcat) |
| `netiq-activemq` | ActiveMQ |
| `netiq-nginx` | NGINX |
| `netiq-golang` | Auxiliary component (newer versions) |

Usage: `systemctl status|start|stop|restart <service>`; logs also via `journalctl -u <service>`.

---

## Configuration files

| File | Default path | Purpose |
|---------|------|-----------|
| `ism-configuration.properties` | `/opt/netiq/idm/apps/tomcat/conf/` | **Main Identity Applications properties**: OSP, SSPR, User App and Role Service URLs, database connections. Do **not** confuse with NAM's Identity Server configuration |
| `sspr.properties` / SSPR configuration | SSPR install directory | SSPR configuration |
| `server.xml` | `/opt/netiq/idm/apps/tomcat/conf/` | Tomcat HTTPS connector (ports, keystore, ciphers) |

Back up any configuration file before editing it.

---

## Good practices

- **Start with logs**: identify the failing component and read its log.
- **Check known errors first** (knowledge base, then OpenText KB).
- **Recursive grep** across logs:
  ```bash
  grep -ril "parameter" /path/to/logs/
  ```
- **Stuck driver**: try restarting from the console, then restarting eDirectory; as a last resort, use `dxcmd`:
  ```bash
  cd /opt/novell/eDirectory/bin
  ./dxcmd -host <edir-host> -user <admin-dn> -s   # omit -password to be prompted
  ```
  Avoid passing passwords on the command line (they end up in shell history and process lists).

---

## Cross-platform

| Aspect | Linux (SLES/RHEL) | Windows |
|---------|-------------------|---------|
| Engine | `/opt/novell/eDirectory/` | `C:\Program Files\Novell\` |
| Identity Apps | `/opt/netiq/idm/apps/tomcat/` | Linux only (recent versions) |
| Remote Loader | `/opt/novell/eDirectory/lib/nds-modules/dirxml/RemoteLoader/` | `C:\Program Files\Novell\RemoteLoader\` |
| eDirectory logs | `/var/opt/novell/eDirectory/log/` | `C:\Novell\NDS\` (or install directory) |
| Services | systemd | services.msc / `Get-Service` |

> Core IDM components (Engine, Identity Apps, SSPR) are Linux-native in current versions. Remote Loader commonly runs on Windows for AD drivers.

---

## Official references

- [Identity Manager documentation](https://www.netiq.com/documentation/identity-manager-410/) (overview and planning, install/upgrade, Identity Applications admin guide)
- [eDirectory documentation](https://www.netiq.com/documentation/edirectory-9/)
- [OpenText Community: Identity](https://community.opentext.com/cybersec/identity/)
