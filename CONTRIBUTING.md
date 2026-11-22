# Contributing

Thanks for helping! Bug reports, corrections against official docs, new skills and translations are all welcome.

1. Read [docs/writing-skills.md](docs/writing-skills.md).
2. Create a branch, make your change, and run `./scripts/validate.sh`.
3. Open a pull request that explains what changed and **which official documentation backs it**.

## Never commit customer data

This repository is public. Before you push, check that your change contains **no** customer or employer names, hostnames, IP addresses, domains, ticket numbers, people's names, internal URLs, screenshots or internal scripts. CI runs a secret scanner and pattern checks, but you are responsible for your content.

## Adding a skill

- Pick the plugin that matches the vendor or topic, or propose a new plugin in your PR.
- Add the skill folder and update the plugin and skills table in `README.md`.
- If it belongs to a plugin that has an agent, add it to the agent's skills table.
- Add a line to `CHANGELOG.md`.

## Code of conduct

Be respectful and constructive. Maintainers may close contributions that do not follow these rules.
