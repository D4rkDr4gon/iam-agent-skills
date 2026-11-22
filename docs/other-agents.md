# Using the skills with other agents

The skills follow the open [Agent Skills](https://agentskills.io/specification) format: a folder with a `SKILL.md` that has YAML frontmatter (`name`, `description`, optional `license`) and optional `references/`, `scripts/` and `assets/`. Any compatible agent can load them.

`scripts/install.sh` (or `install.ps1` on Windows) symlinks every skill folder into a target directory. Re-run it after `git pull` to pick up new skills. Existing skills update in place because they are symlinks.

| Agent | Typical skills directory (user level) |
|---|---|
| Claude Code | Use the plugin marketplace (see README), or `~/.claude/skills/` |
| OpenAI Codex | `~/.agents/skills/` (or `~/.codex/skills/` on older versions) |
| Gemini CLI | `~/.gemini/skills/` |
| opencode | `~/.config/opencode/skills/` (it also reads `~/.claude/skills/`) |
| Cursor / VS Code / others | See the agent's documentation for its skills directory |

Directory names change between versions. Check your agent's docs if a skill does not show up.

The **agents** (`plugins/*/agents/*.md`) use Claude Code's subagent format. Other tools may need a different format, but the body text works as a system prompt anywhere.

## Examples

```bash
./scripts/install.sh --target ~/.agents/skills                       # all skills
./scripts/install.sh --target ~/.gemini/skills --plugin opentext-identity
./scripts/install.sh --target ~/.config/opencode/skills --copy        # copy instead of symlink
./scripts/install.sh --target ~/.agents/skills --uninstall
```
