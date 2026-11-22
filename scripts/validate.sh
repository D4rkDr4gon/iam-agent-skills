#!/usr/bin/env bash
# Validate skills and manifests. Exit code 1 on any error.
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
errors=0
err() { printf 'ERROR: %b\n' "$*" >&2; errors=$((errors+1)); }

# JSON manifests
for f in .claude-plugin/marketplace.json plugins/*/.claude-plugin/plugin.json; do
  python3 -m json.tool "$f" >/dev/null 2>&1 || err "$f: invalid JSON"
done

# Every plugin listed in the marketplace exists and vice versa
listed=$(python3 -c 'import json;print("\n".join(p["source"].removeprefix("./") for p in json.load(open(".claude-plugin/marketplace.json"))["plugins"]))' | sort)
actual=$(find plugins -mindepth 1 -maxdepth 1 -type d | sort)
[[ "$listed" == "$actual" ]] || err "marketplace plugins ($listed) differ from plugins/ ($actual)"

# Skills
for skill_md in plugins/*/skills/*/SKILL.md; do
  dir=$(basename "$(dirname "$skill_md")")
  head -1 "$skill_md" | grep -q '^---$' || { err "$skill_md: missing frontmatter"; continue; }
  name=$(awk '/^---$/{n++; next} n==1 && /^name:/{sub(/^name:[ ]*/,""); print; exit}' "$skill_md")
  [[ "$name" == "$dir" ]] || err "$skill_md: name '$name' != folder '$dir'"
  [[ "$name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ && ${#name} -le 64 ]] || err "$skill_md: invalid name '$name'"
  grep -q '^description:' "$skill_md" || err "$skill_md: missing description"
  lines=$(wc -l < "$skill_md"); [[ $lines -le 500 ]] || err "$skill_md: $lines lines (> 500)"
  grep -q 'AGENT_KB_DIR' "$skill_md" || err "$skill_md: missing 'Local knowledge base' section"
done
for d in plugins/*/skills/*/; do [[ -f "$d/SKILL.md" ]] || err "$d: no SKILL.md"; done

# Agents
for a in plugins/*/agents/*.md; do
  [[ -e "$a" ]] || continue
  grep -q '^name:' "$a" && grep -q '^description:' "$a" || err "$a: missing name/description"
done

# Forbidden patterns (generic; maintainers may run an extra private denylist)
patterns=(
  '\b(10\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})\b'
  '\b192\.168\.[0-9]{1,3}\.[0-9]{1,3}\b'
  '\b172\.(1[6-9]|2[0-9]|3[01])\.[0-9]{1,3}\.[0-9]{1,3}\b'
  '/home/[a-z]'
  'C:\\Users\\[A-Za-z]'
  '[A-Za-z0-9._%+-]+@(gmail|hotmail|outlook|yahoo)\.'
  'BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY'
)
allow='10\.0\.0\.10'   # documentation example IP used in enterprise-certificates
for p in "${patterns[@]}"; do
  hits=$(grep -rEn --exclude-dir=.git --exclude=validate.sh -e "$p" . | grep -Ev "$allow" || true)
  [[ -z "$hits" ]] || err "forbidden pattern '$p':\n$hits"
done

if [[ $errors -gt 0 ]]; then echo "validation failed: $errors error(s)"; exit 1; fi
echo "validation passed"
