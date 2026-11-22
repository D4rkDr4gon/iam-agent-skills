---
name: nam-access-manager
description: >
  Use when configuring or troubleshooting OpenText (NetIQ) Access Manager (NAM): Identity
  Server (SAML/OAuth/OIDC IdP), Access Gateway (Apache-based reverse proxy), Administration
  Console, Analytics; contracts, user stores, methods, form fill, role policies, Advanced
  Options (Apache directives), session cookies, health endpoints, logs, authentication and
  SSO troubleshooting.
license: Apache-2.0
---

# nam-access-manager

## Purpose

Configure, operate and troubleshoot **OpenText Access Manager (NAM)** (formerly NetIQ / Micro Focus / Novell Access Manager).

**Out of scope**: certificate procedures (`enterprise-certificates`), IDM drivers (`idm-identity-drivers`), IDM servers (`idm-identity-servers`), workflow forms (`idm-workflow-forms`).

> **Generic by design.** No customer data. Always work from the environment the user describes. Paths are product defaults; confirm on the servers.

## Local knowledge base (optional)

Before answering from memory, check whether the user configured a knowledge base:

1. The environment variable `AGENT_KB_DIR` (a folder of notes or docs), or
2. A "Knowledge base" section in `CLAUDE.md` / `AGENTS.md` naming a path or a skill to use for reading it.

If present, search it first (or delegate to the named skill) and cite the note you used. If absent, rely on official OpenText documentation and say so. Never write to the knowledge base unless the user asks.

---

## Technical context

### Components

| Component | Role | Technology |
|-----------|-----|-----------------|
| **Identity Server (IdP)** | SAML 2.0 / OAuth / OIDC identity provider: authentication, tokens, policies | Tomcat |
| **Access Gateway (AG)** | Reverse proxy protecting web resources: SSO, form fill, header injection | **Apache HTTPD 2.4** + Tomcat (AJP) |
| **Administration Console** | Central web configuration console | Tomcat |
| **Analytics Server** | Dashboards, reports, auditing | Elastic/Kibana stack |

### Deployment models

1. **Individual components** on separate servers (also Docker, AWS, Azure).
2. **Access Manager Appliance**: all-in-one on SUSE Linux Enterprise Server (Identity Server + Access Gateway + Admin Console).

### Access Gateway and Apache

- The AG runs on **Apache HTTPD 2.4**. Global and per-proxy-service **Advanced Options** accept documented `NAG*` options and also native Apache directives.
- Apache ↔ Tomcat communication uses **AJP** (`mod_proxy_ajp`).
- This allows directives such as `Header always set`, `RequestHeader set/unset`, `SSLProtocol`, `SSLCipherSuite`, `LogLevel` from the NAM UI.
- A wrong directive can take the AG down; test in non-production first.

### Configuration hierarchy

```
Administration Console
  ├── Identity Server
  │     ├── User Stores (eDirectory, AD, LDAP)
  │     ├── Methods (Name/Password, X.509, Kerberos, OAuth, …)
  │     ├── Contracts (methods + user store + policies)
  │     ├── Shared Settings (secret stores, custom attributes)
  │     └── Defaults (default contract / user store)
  ├── Access Gateway
  │     ├── Reverse proxies / proxy services
  │     ├── Protected resources
  │     ├── Form Fill policies
  │     ├── Role policies
  │     ├── Advanced Options (global and per proxy service)
  │     └── TLS certificates
  └── Analytics Server
```

---

## Working protocol

### 1. Get the environment context

Ask, unless already stated:

- New or existing environment?
- NAM version (4.5, 5.0, 5.1 Appliance, CE 24.x, …) and deployment model
- Components involved (IdP, AG, Analytics)
- User store (eDirectory, AD, other LDAP)
- Cluster / HA?
- Relevant URLs / FQDNs / ports

### 2. Check the local knowledge base

See "Local knowledge base (optional)".

### 3. Official sources

Administration and security guides for the user's version (see References), OpenText KB and Community.

### 4. Answer

Base the answer on the knowledge base (if any) plus official documentation; say so when neither covers it.

### 5. Document (only if the user asks)

---

## Good practices

### General configuration
- **Always use HTTPS**; Secure Name/Password methods require TLS.
- **Insecure default contracts**: `Name/Password - Basic` and `Name/Password - Form` ship enabled. Remove or replace them with `Secure Name/Password` in production.
- **MFA**: associate several methods with one contract.
- **User store order matters**: the order in a method is the search order; put the store with most users first.
- **OU restriction** is configured on the user store, not the contract.

### Session cookies
- `JSESSIONID` → Identity Server (path `/nidp`)
- `IPC` (Identity Proxy Cookie) → Access Gateway
- `SPC` (Session Proxy Cookie) → Access Gateway
- Recommended attributes: `HttpOnly`, `Secure`, `SameSite=Lax|Strict`

### Advanced Options
- Prefer documented `NAG*` options (officially supported).
- Native Apache directives work for uncovered cases (e.g. custom header injection) but are **not officially supported**.
- `DumpResponseHeaders on` helps debugging; **never leave it on in production** (huge logs).
- Keep a changelog of every Advanced Option applied.

### Form Fill
- Only `content-type: text/html`.
- For JavaScript-heavy forms use `InPlaceSilent=on` + `InPlaceSilentPolicyDoesSubmit=on`.
- Shared secrets live in Identity Server → Shared Settings → Custom Attributes.

---

## Troubleshooting

### Logs (Linux defaults)

| Component | Log | Path |
|-----|------|-----------|
| Identity Server | catalina.out (authentication, SAML, OAuth, policy evaluation) | `/var/opt/novell/nam/logs/idp/tomcat/catalina.out` |
| Identity Server | Access log | `/var/opt/novell/nam/logs/idp/tomcat/localhost_access_log.*.txt` |
| Access Gateway | Apache error_log | `/var/opt/novell/nam/logs/mag/apache2/error_log` |
| Access Gateway | Tomcat/ESP (form fill, policies) | `/var/opt/novell/nam/logs/mag/tomcat/catalina.out` |
| Access Gateway | Reverse proxy transaction logs (if enabled) | `/var/log/novell/reverse/` |
| Access Gateway | JCC (AG ↔ Admin Console: imports, certs, health) | `/var/opt/novell/nam/logs/jcc/` |
| Access Gateway | Gateway service errors / verbose | `/var/opt/novell/nam/logs/mag/amlogging/` |
| Admin Console | catalina.out | `/var/opt/novell/nam/logs/ac/tomcat/catalina.out` |
| Analytics | Dashboard logs | `/var/opt/novell/nam/logs/dashboard/` |

### systemd services

| Service | Component |
|----------|-----------|
| `novell-idp` | Identity Server |
| `novell-mag` | Access Gateway |
| `novell-apache2` | Apache HTTPD (AG) |
| `novell-jcc` | JCC (AG ↔ AC communication) |
| `novell-ac` / `novell-tomcat*` | Administration Console (name varies by version) |
| `novell-activemq` | ActiveMQ |

### Health endpoints

```
https://<idp-fqdn>:<port>/nidp/heartbeat        # Identity Server, HTTP 200 when healthy
https://<ag-fqdn>:<port>/nesp/app/heartbeat     # Access Gateway (used by L4 load balancers)
https://<ac-fqdn>:8443/nps                       # Administration Console
```

### Tools

| Tool | Use |
|------------|-----|
| **Re-push configuration** | Admin Console → Troubleshooting → Re-push current configuration; forces the AG to apply current config |
| **Health status** | Admin Console → Devices → Access Gateways / Identity Servers → Health |
| **curl** | Connectivity, IdP metadata, health endpoints |
| **tail -f** | Live logs |
| **tcpdump** | Traffic capture (AJP, SSO redirects) |
| **DumpResponseHeaders** | Global Advanced Option; dumps HTTP headers to the AG log directory |
| **Policy tracing** | Identity Server → Auditing and Logging → *Echo to console*, level info/config, to see policy evaluation in catalina.out |

### Common issues

| Symptom | Likely cause | Action |
|---|---|---|
| "Unable to read keystore" | Keystore password/alias mismatch, corrupted or expired keystore after a certificate change | Check the keystore in the Admin Console certificate store, re-push certificates (see `enterprise-certificates`) |
| User matched twice / wrong identity | The same user exists in several user stores or matches several search contexts | Review user store order, search contexts and uniqueness of the login attribute |
| AG not reflecting changes | Configuration not applied | Check the AG status, apply changes or re-push the configuration |
| Analytics disk full | Index retention too long | Adjust retention, purge old indices, extend the disk |
| Vulnerability scan flags weak TLS (e.g. ROBOT) | RSA key-exchange ciphers enabled | Restrict `SSLCipherSuite` to ECDHE suites and update `SSLProtocol` via Advanced Options / TLS settings |
| SSO loop / repeated login | Cookie domain/path, clock skew, SameSite blocking | Inspect cookies and redirects; check NTP |

### Method

1. Start with the failing component's log: authentication → IdP, proxying → AG.
2. Check the health endpoints before diving into logs.
3. For policies, enable policy tracing temporarily.
4. Re-push configuration if the AG ignores changes.
5. Verify network paths between IdP ↔ AG ↔ Admin Console ↔ LDAP.

---

## Platform

NAM server components are Linux-native (SLES/RHEL, appliance on SLES). From Windows you only use the browser-based Administration Console.

---

## Official references

- [Access Manager documentation](https://www.microfocus.com/documentation/access-manager/) (administration, security and installation guides per version)
- [OpenText Community: Access Manager](https://community.opentext.com/cybersec/nam/)
