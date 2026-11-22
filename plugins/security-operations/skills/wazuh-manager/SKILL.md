---
name: wazuh-manager
description: >
  Use when deploying, operating or integrating Wazuh SIEM/XDR: architecture (manager,
  indexer, dashboard, agents), Docker Compose deployment, agent enrollment and management,
  the manager REST API, querying alerts in the indexer, custom rules and decoders, and
  SOAR / threat-intel integrations (VirusTotal, TheHive, Cortex, MISP, Slack, Shuffle).
  Lab- and installation-agnostic.
license: Apache-2.0
---

# wazuh-manager

## Purpose

Deploy, operate, tune and integrate **Wazuh**, the open-source SIEM/XDR platform.

> **Generic by design.** Use placeholders for hosts and secrets. Never hard-code API or indexer passwords. Read them from environment variables or a secrets manager.

## Local knowledge base (optional)

Before answering from memory, check whether the user configured a knowledge base:

1. The environment variable `AGENT_KB_DIR` (a folder of notes or docs), or
2. A "Knowledge base" section in `CLAUDE.md` / `AGENTS.md` naming a path or a skill to use for reading it.

If one exists, search it first (or delegate to the named skill) and cite the note you used. If there is no knowledge base, rely on the official Wazuh documentation and say so. Never write to the knowledge base unless the user asks.

---

## Architecture

| Component | Role | Typical ports |
|------------|-----|------------------|
| **wazuh-manager** | Receives agent events, applies decoders and rules, triggers integrations and active response | 1514 (agents), 1515 (enrollment), 55000 (REST API), 1516 (cluster) |
| **wazuh-indexer** | Stores and indexes alerts (OpenSearch-based) | 9200 |
| **wazuh-dashboard** | Web UI (OpenSearch Dashboards + Wazuh plugin) | 443 |
| **wazuh-agent** | Runs on monitored endpoints and sends events to the manager on 1514 | — |

How it fits together: the agent collects data (logs, FIM, rootcheck, syscollector). The manager decodes it and applies rules. Hits at a high enough level are indexed, and they can also trigger integrations.

## Docker Compose deployment (single node)

Use the official `wazuh-docker` repository for your version (`single-node/` directory):

```bash
# 1. Kernel prerequisite for OpenSearch
echo 'vm.max_map_count=262144' | sudo tee /etc/sysctl.d/99-wazuh.conf
sudo sysctl --system

# 2. Generate inter-component TLS certificates (from the single-node directory)
docker compose -f generate-indexer-certs.yml run --rm generator

# 3. Start the stack
docker compose up -d

# 4. Check health
docker compose ps
```

Notes:
- The indexer needs dedicated memory (at least `OPENSEARCH_JAVA_OPTS=-Xms1g -Xmx1g`) and unlimited `memlock`.
- Change every default password (indexer `admin`, API `wazuh-wui`, dashboard users) before exposing the stack.
- On a single node, optional daemons (`wazuh-clusterd`, `wazuh-maild`) may be stopped. That is normal.
- The dashboard depends on a healthy indexer. If the indexer does not start, neither will the dashboard.

## Agent management

```bash
# Enroll from the endpoint (agent already installed)
sudo /var/ossec/bin/agent-auth -m <manager-host> [-P <enrollment-password>]
sudo systemctl enable --now wazuh-agent

# Manual/offline registration from the manager
/var/ossec/bin/manage_agents       # (A) add → (E) extract key → manage_agents -i <key> on the agent
```

## Manager REST API (port 55000)

```bash
TOKEN=$(curl -sk -u "wazuh-wui:$WAZUH_API_PASSWORD" -X POST \
  "https://<manager>:55000/security/user/authenticate" | jq -r .data.token)

curl -sk -H "Authorization: Bearer $TOKEN" "https://<manager>:55000/manager/status"
curl -sk -H "Authorization: Bearer $TOKEN" "https://<manager>:55000/agents?status=active"
curl -sk -H "Authorization: Bearer $TOKEN" "https://<manager>:55000/rules"
curl -sk -H "Authorization: Bearer $TOKEN" "https://<manager>:55000/decoders"
curl -sk -H "Authorization: Bearer $TOKEN" -X PUT "https://<manager>:55000/agents/<id>/restart"
```

## Querying alerts (indexer, port 9200)

Alerts are stored in the indexer, in the `wazuh-alerts-*` indices, not on the manager:

```bash
curl -sk -u "admin:$INDEXER_PASSWORD" "https://<indexer>:9200/wazuh-alerts-*/_search" \
  -H 'Content-Type: application/json' -d '{
    "query": { "bool": { "filter": [
      { "range": { "rule.level": { "gte": 7 } } },
      { "range": { "@timestamp": { "gte": "now-24h" } } }
    ]}},
    "sort": [{ "@timestamp": "desc" }], "size": 50 }'
```

## Custom rules and decoders

```
/var/ossec/etc/rules/local_rules.xml       # custom rules (IDs 100000–120000)
/var/ossec/etc/decoders/local_decoder.xml  # custom decoders
/var/ossec/bin/wazuh-logtest               # test before deploying
```

```xml
<group name="local,custom_group,">
  <rule id="100100" level="10">
    <if_sid>5716</if_sid>
    <match>authentication failed</match>
    <description>Repeated authentication failure: possible brute force</description>
  </rule>
</group>
```

## Integrations

Integrations are declared in `ossec.conf`:

```xml
<integration>
  <name>NAME</name>            <!-- built-in (virustotal, slack, pagerduty, shuffle, maltiverse) or custom-* -->
  <api_key>…</api_key>         <!-- if needed -->
  <level>3</level>             <!-- minimum alert level -->
  <group>syscheck</group>      <!-- optional -->
  <alert_format>json</alert_format>
</integration>
```

- **Built-in**: the script already ships with the manager, so you only configure it.
- **Custom** (`custom-<name>`): put two files in `/var/ossec/integrations/`, a shell wrapper and a `.py` script. The script receives the alert JSON and calls the external API. Both must be executable and owned by `root:wazuh`.

| Integration | What it adds | Pattern |
|-------------|------------|--------|
| **VirusTotal** | Hash lookups for FIM detections | Built-in |
| **TheHive** | Turns alerts into cases | Custom script → TheHive API |
| **Cortex** | Analyzers for TheHive observables (VT, MISP, abuse.ch, Shodan, …) | Through TheHive |
| **MISP** | IOC feeds for correlation (CDB lists) or through Cortex | Periodic list updates |
| **Slack / Discord / Telegram** | Real-time notifications | Built-in (Slack) or custom |
| **Shuffle** | Visual SOAR playbooks | Built-in |

To debug an integration:

```bash
grep -i integrat /var/ossec/logs/ossec.log | tail -30   # expect "Enabling integration for 'X'"
```

## Troubleshooting

| Symptom | Likely cause | Fix |
|---------|-----------------|-----|
| Indexer does not start or crashes | `vm.max_map_count` too low, not enough heap | Set the sysctl and adjust `OPENSEARCH_JAVA_OPTS` |
| Manager "unhealthy" but working | Optional daemons stopped on a single node | Check `wazuh-analysisd`, `wazuh-remoted` and `wazuh-db` with `wazuh-control status` |
| Agent does not enroll | `wazuh-authd` not listening or 1515 blocked | Check authd and the firewall. Read `ossec.log` |
| Integration never fires | `<level>` higher than the actual alerts, or script not executable | Check `wazuh-integratord` logs and permissions |
| Lost indexer password | — | Use the Wazuh password tool or the OpenSearch security `hash.sh` + `internal_users.yml`, then restart |
| Dashboard rejected by browser | Self-signed certificate | Trust the generated root CA, or install a proper certificate |

## Cheatsheet

```bash
docker compose ps
docker compose logs wazuh.manager --tail 100
docker compose exec wazuh.manager tail -f /var/ossec/logs/ossec.log
docker compose exec wazuh.manager /var/ossec/bin/wazuh-control status
```

## References

- [Wazuh documentation](https://documentation.wazuh.com/current/)
- [wazuh-docker](https://github.com/wazuh/wazuh-docker)
- [Wazuh API reference](https://documentation.wazuh.com/current/user-manual/api/reference.html)
