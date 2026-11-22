# Writing and changing skills

## Conventions

- **One folder per skill** under `plugins/<plugin>/skills/<skill-name>/`.
- `name` in the frontmatter is **lowercase, digits and hyphens**, and must **match the folder name**.
- `description` (≤ 1024 characters) says **what** the skill does and **when** to use it. Write it in English and include the product names and keywords users will type.
- Keep `SKILL.md` under **500 lines**. Move long reference material into `references/*.md` and link it from `SKILL.md` (progressive disclosure).
- Put executable helpers in `scripts/` and templates in `assets/`.
- Use only standard frontmatter fields (`name`, `description`, `license`, `metadata`, `allowed-tools`, `compatibility`) so the skill stays portable.

## Required sections

Every skill must include:

1. **Purpose**, plus what is out of scope (with the sibling skill to use instead).
2. **Local knowledge base (optional)**: copy the exact block from an existing skill.
3. **Working protocol**: ask for context, check the knowledge base, use official sources, answer, document only on request.
4. **References** to official vendor documentation.

## Generic by design: hard rules

- No customer or employer names, hostnames, IPs, domains, ticket numbers, people's names, internal URLs or internal scripts.
- No real secrets. Use placeholders (`<admin-dn>`, `$API_PASSWORD`) and prompt for passwords instead of putting them on the command line.
- Only state product behaviour you can back with official documentation. If unsure, the skill must say so.
- Paths are product defaults and must be labeled as such.

## Validate

```bash
./scripts/validate.sh            # frontmatter, naming, size, forbidden patterns, JSON manifests
claude plugin validate .         # if you have Claude Code
```
