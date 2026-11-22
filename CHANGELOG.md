# Changelog

All notable changes are documented here. Versions follow [SemVer](https://semver.org/) per marketplace release.

## [Unreleased]

### Removed
- `security-operations` plugin (`wazuh-manager`) moved to [security-agent-skills](https://github.com/D4rkDr4gon/security-agent-skills).

## [0.1.0]

### Added
- `one-identity` plugin: `oneim-manager`, `oneim-customization`, `oneim-active-roles`, `oneim-onelogin`, `oneim-password-manager`, `oneim-safeguard`, `oneim-starling`, and the `one-identity-specialist` agent.
- `opentext-identity` plugin: `idm-identity-servers`, `idm-identity-drivers`, `idm-workflow-forms`, `nam-access-manager`, `iam-health-check`, and the `opentext-iam-specialist` agent.
- `enterprise-pki` plugin: `enterprise-certificates`.
- Optional knowledge-base integration (`AGENT_KB_DIR` or a "Knowledge base" section in CLAUDE.md/AGENTS.md).
- Install scripts for other agents, a validation script and CI.
