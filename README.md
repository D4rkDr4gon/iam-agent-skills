# iam-agent-skills

Generic [Agent Skills](https://agentskills.io) for **Identity & Access Management**: One Identity, OpenText (NetIQ) Identity Manager and Access Manager, enterprise PKI and Wazuh.

- **Installation-agnostic.** The skills contain no customer data. They ask for your environment's context and then apply official vendor documentation.
- **Bring your own knowledge.** Point the skills at your own notes or runbooks and they consult those first. See [docs/customization.md](docs/customization.md).
- **Portable.** These are plain `SKILL.md` folders that follow the open Agent Skills format. The repo is packaged as a Claude Code plugin marketplace and also works with Codex, Gemini CLI, opencode, Cursor and other compatible agents.

## Plugins and skills

| Plugin | Skills | Agent |
|---|---|---|
| **one-identity** | `oneim-manager`, `oneim-customization`, `oneim-active-roles`, `oneim-onelogin`, `oneim-password-manager`, `oneim-safeguard`, `oneim-starling` | `one-identity-specialist` |
| **opentext-identity** | `idm-identity-servers`, `idm-identity-drivers`, `idm-workflow-forms`, `nam-access-manager`, `iam-health-check` | `opentext-iam-specialist` |
| **enterprise-pki** | `enterprise-certificates` | — |
| **security-operations** | `wazuh-manager` | — |

## Install

### Claude Code

```text
/plugin marketplace add D4rkDr4gon/iam-agent-skills
/plugin install one-identity@iam-agent-skills
/plugin install opentext-identity@iam-agent-skills
/plugin install enterprise-pki@iam-agent-skills
/plugin install security-operations@iam-agent-skills
```

Install only the plugins you need. To update, run `/plugin marketplace update iam-agent-skills`.

### Other agents (Codex, Gemini CLI, opencode, Cursor, …)

```bash
git clone https://github.com/D4rkDr4gon/iam-agent-skills.git
cd iam-agent-skills
./scripts/install.sh --target ~/.agents/skills          # symlinks every skill
./scripts/install.sh --target ~/.config/opencode/skills --plugin one-identity
```

On Windows, use `scripts/install.ps1 -Target <dir>`. See [docs/other-agents.md](docs/other-agents.md) for each agent's skills directory.

## Use

Skills trigger automatically from their description. For example, ask *"Safeguard password check fails on Windows servers"* or *"build a dependent select in an IDM JSON form"*. You can also invoke one by name, e.g. `/oneim-safeguard`.

Each skill:
1. asks for the context it needs (versions, topology, components);
2. checks your knowledge base, if one is configured;
3. answers from official documentation, and says so when it is not sure;
4. never writes to your knowledge base unless you ask.

## Repository layout

```
.claude-plugin/marketplace.json   # marketplace catalog
plugins/<plugin>/
  .claude-plugin/plugin.json
  skills/<skill>/SKILL.md          # + optional references/, scripts/, assets/
  agents/<agent>.md
docs/                              # customization, other agents, writing skills
scripts/                           # install + validate
```

## Contributing

Contributions are welcome. Read [CONTRIBUTING.md](CONTRIBUTING.md) first. The most important rule: **never commit customer data**, including hostnames, IPs, domains, tickets, names or internal scripts.

## Disclaimer

This is an independent community project. It is not affiliated with or endorsed by One Identity, OpenText, Wazuh or any other vendor mentioned. Product names are trademarks of their owners. Always validate changes in a non-production environment.

## License

[Apache-2.0](LICENSE)
