---
name: enterprise-certificates
description: >
  Use when creating, renewing, converting or troubleshooting TLS certificates in enterprise
  Java / LDAP / identity platforms: keystores (JKS, PKCS12), keytool, OpenSSL, CSRs with
  SANs, wildcard certificates, trust chains and truststores, certificate replacement in
  Tomcat / NGINX / Apache, eDirectory Certificate Server, NetIQ iManager and Access Manager.
  Linux and Windows.
license: Apache-2.0
---

# enterprise-certificates

## Purpose

Handle the full lifecycle of server certificates in enterprise platforms: generate keys and CSRs, get them signed, build keystores, install them, renew them before expiry and debug trust problems.

> **Generic by design.** Never ask the user to paste private keys or keystore passwords into the chat. Use placeholders and let the user type secrets locally. Always back up a keystore before changing it.

## Local knowledge base (optional)

Before answering from memory, check whether the user configured a knowledge base:

1. The environment variable `AGENT_KB_DIR` (a folder of notes or docs), or
2. A "Knowledge base" section in `CLAUDE.md` / `AGENTS.md` naming a path or a skill to use for reading it.

If one exists, search it first (or delegate to the named skill) and cite the note you used. Per-product renewal runbooks are common there. If there is no knowledge base, rely on vendor documentation and say so. Never write to the knowledge base unless the user asks.

---

## Concepts

| Concept | Notes |
|---|---|
| **Key pair** | RSA 2048+ (3072/4096 for long-lived certificates) or ECDSA P-256; signature SHA-256 or stronger |
| **CSR** | Certificate signing request: subject plus SANs plus public key |
| **SAN** | Subject Alternative Names. Modern clients **ignore the CN**, so every FQDN, short name and IP used to reach the service must be a SAN |
| **Wildcard** | `*.example.com` covers one label only (not `a.b.example.com`, not the apex) |
| **Chain** | Leaf → intermediate(s) → root. Servers must send leaf plus intermediates |
| **Keystore** | Holds the private key and its chain (JKS, PKCS12, PEM pair) |
| **Truststore** | Holds trusted CA certificates (Java `cacerts`, OS trust store) |
| **Formats** | PEM (Base64 text), DER (binary), PKCS12 (`.p12`/`.pfx`, key + chain), JKS (legacy Java) |
| **Validity** | Public CAs issue certificates for 398 days at most, and that maximum keeps shrinking. Internal CAs set their own policy |

---

## Working protocol

1. **Context**: product and component, current keystore type and location, which CA signs (public, internal enterprise CA, eDirectory tree CA), names and IPs clients use, clustered or not, and the expiry date of the current certificate.
2. **Inventory first**: inspect the current certificate and keystore (commands below) so the new one keeps the same alias, names and key usage.
3. **Plan**: generate a new key + CSR (preferred), or reuse the key only if policy allows. Write down every file and password placeholder.
4. **Back up**: copy keystores and configuration files before you touch them.
5. **Install**: import the chain, update the configuration, then restart or reload the service.
6. **Verify**: check from the client side with `openssl s_client` and check expiry. Update monitoring.
7. **Document** only if the user asks.

---

## Command reference

### Inspect

```bash
openssl x509 -in cert.pem -noout -subject -issuer -dates -ext subjectAltName
openssl req  -in request.csr -noout -text -verify
openssl s_client -connect host.example.com:443 -servername host.example.com -showcerts </dev/null
openssl s_client -connect ldap.example.com:636 -showcerts </dev/null      # LDAPS
keytool -list -v -keystore keystore.p12 -storetype PKCS12                  # prompts for password
```

### Key + CSR with SANs (OpenSSL)

```bash
openssl req -new -newkey rsa:3072 -nodes -keyout server.key -out server.csr \
  -subj "/CN=host.example.com/O=Example" \
  -addext "subjectAltName=DNS:host.example.com,DNS:host,IP:10.0.0.10"
```

### Key + CSR with SANs (keytool)

```bash
keytool -genkeypair -alias server -keyalg RSA -keysize 3072 -sigalg SHA256withRSA \
  -dname "CN=host.example.com, O=Example" \
  -ext "SAN=dns:host.example.com,dns:host,ip:10.0.0.10" \
  -keystore server.p12 -storetype PKCS12
keytool -certreq -alias server -keystore server.p12 -file server.csr \
  -ext "SAN=dns:host.example.com,dns:host,ip:10.0.0.10"
```

The SAN must be repeated in `-certreq`. keytool does not copy it from the key entry.

### Import the signed certificate (keytool)

```bash
keytool -importcert -trustcacerts -alias root  -file root.pem         -keystore server.p12
keytool -importcert -trustcacerts -alias inter -file intermediate.pem -keystore server.p12
keytool -importcert -alias server -file server.pem -keystore server.p12   # same alias as the key
```

### Conversions

```bash
# PEM key + chain → PKCS12
openssl pkcs12 -export -inkey server.key -in server.pem -certfile chain.pem -name server -out server.p12
# PKCS12 → PEM
openssl pkcs12 -in server.p12 -nokeys -out chain.pem
openssl pkcs12 -in server.p12 -nocerts -nodes -out server.key       # protect this file
# JKS → PKCS12
keytool -importkeystore -srckeystore old.jks -srcstoretype JKS -destkeystore new.p12 -deststoretype PKCS12
# DER ↔ PEM
openssl x509 -inform der -in cert.cer -out cert.pem
```

### Trust a CA in Java

```bash
keytool -importcert -trustcacerts -alias corp-root -file root.pem \
  -keystore "$JAVA_HOME/lib/security/cacerts"        # default password is usually "changeit"
```

Products often ship their own JRE (for example under `/opt/netiq/common/jre`). Import into the truststore the service actually uses.

---

## Product notes

| Product / component | Where the certificate lives | Notes |
|---|---|---|
| **Tomcat** (Identity Apps, Access Manager, iManager, …) | `server.xml` connector → `certificateKeystoreFile` / `keystoreFile` | Keep the alias and password in sync with `server.xml`, then restart Tomcat |
| **NGINX** | `ssl_certificate` (leaf + intermediates, in that order) / `ssl_certificate_key` | `nginx -t`, then reload |
| **Apache HTTPD** | `SSLCertificateFile` / `SSLCertificateKeyFile` (+ `SSLCertificateChainFile` on old versions) | `apachectl configtest` |
| **eDirectory** | Server certificates (`SSL CertificateDNS`, `SSL CertificateIP`) issued by the tree CA via **Certificate Server** in iManager / Identity Console | For LDAPS from a public or enterprise CA, import the key/cert into a new KMO and point the LDAP Server object at it. Refresh LDAP afterwards |
| **iManager** | Its own Tomcat keystore | Same as Tomcat |
| **Access Manager** | Admin Console → Security → Certificates: keystores per device (signing, encryption, SSL, trusted roots) | Replace the certificate in the keystore and push it to devices. "Unable to read keystore" usually means an alias or password mismatch |
| **Identity Manager Remote Loader** | Trusted root (tree CA) on the Remote Loader host, or keystore per instance | Driver and Remote Loader must trust the same CA |
| **Windows / IIS / AD** | Machine store (`certlm.msc`) | Use `certreq` with an INF file (SAN extension), or MMC. For LDAPS on DCs, the certificate must be in the NTDS or machine Personal store |

---

## Renewal checklist

- [ ] Inventory every endpoint that uses the certificate, including load balancers and cluster nodes
- [ ] The new CSR has all SANs and the right key size and algorithm
- [ ] Chain complete (intermediates included), root trusted by every client
- [ ] Keystores backed up, then updated with the same alias
- [ ] Services restarted or reloaded on every node
- [ ] Verified with `openssl s_client` from a client network
- [ ] Old certificate removed from keystores once nothing uses it
- [ ] Expiry monitoring updated

## Troubleshooting

| Symptom | Likely cause | Action |
|---|---|---|
| `PKIX path building failed` (Java) | Issuer not in the truststore the JVM uses | Import root/intermediate into the right `cacerts` |
| Browser "name mismatch" | Name not in SAN | Reissue with every name as a SAN |
| `unable to get local issuer certificate` | Server not sending intermediates | Serve the full chain |
| Keystore loads but the service uses the old certificate | Wrong alias, or service not restarted | Check the alias in the config and restart |
| `keystore password was incorrect` / "unable to read keystore" | Password or store type mismatch | Check store type (JKS vs PKCS12) and the password in config |
| `key values mismatch` (NGINX/Apache) | Certificate does not belong to the key | Compare `openssl x509 -noout -modulus` and `openssl rsa -noout -modulus` hashes |

## References

- [OpenSSL documentation](https://docs.openssl.org/)
- [keytool reference (Java SE)](https://docs.oracle.com/en/java/javase/21/docs/specs/man/keytool.html)
- [eDirectory administration guide: Certificate Server](https://www.netiq.com/documentation/edirectory-9/)
- [Access Manager administration guide: Security and certificates](https://www.microfocus.com/documentation/access-manager/)
