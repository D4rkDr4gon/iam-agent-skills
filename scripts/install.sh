#!/usr/bin/env bash
# Install (symlink or copy) skills from this repo into an agent's skills directory.
# Usage: install.sh --target <dir> [--plugin <name>]... [--copy] [--uninstall]
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target="" ; mode="link" ; uninstall=0 ; plugins=()

usage() { sed -n '2,3p' "$0" | sed 's/^# \{0,1\}//'; exit "${1:-0}"; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)    target="${2:?}"; shift 2 ;;
    --plugin)    plugins+=("${2:?}"); shift 2 ;;
    --copy)      mode="copy"; shift ;;
    --uninstall) uninstall=1; shift ;;
    -h|--help)   usage 0 ;;
    *) echo "unknown option: $1" >&2; usage 1 ;;
  esac
done
[[ -n "$target" ]] || usage 1

if [[ ${#plugins[@]} -eq 0 ]]; then
  mapfile -t plugins < <(find "$repo_root/plugins" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort)
fi

mkdir -p "$target"
count=0
for plugin in "${plugins[@]}"; do
  skills_dir="$repo_root/plugins/$plugin/skills"
  [[ -d "$skills_dir" ]] || { echo "no such plugin: $plugin" >&2; exit 1; }
  for skill in "$skills_dir"/*/; do
    skill="${skill%/}"; name="$(basename "$skill")"; dest="$target/$name"
    if [[ $uninstall -eq 1 ]]; then
      if [[ -L "$dest" && "$(readlink "$dest")" == "$skill" ]] || [[ -f "$dest/.iam-agent-skills" ]]; then
        rm -rf "$dest"; echo "removed $dest"; count=$((count+1))
      fi
      continue
    fi
    if [[ -e "$dest" && ! -L "$dest" && ! -f "$dest/.iam-agent-skills" ]]; then
      echo "skip $name: $dest exists and was not installed by this script" >&2; continue
    fi
    rm -rf "$dest"
    if [[ "$mode" == "link" ]]; then
      ln -s "$skill" "$dest"
    else
      cp -R "$skill" "$dest"; touch "$dest/.iam-agent-skills"
    fi
    echo "$mode $name → $dest"; count=$((count+1))
  done
done
echo "done: $count skill(s)"
