<#
.SYNOPSIS
  Install (symlink or copy) skills from this repo into an agent's skills directory.
.EXAMPLE
  ./scripts/install.ps1 -Target "$HOME\.agents\skills"
  ./scripts/install.ps1 -Target "$HOME\.gemini\skills" -Plugin opentext-identity -Copy
#>
param(
  [Parameter(Mandatory)] [string] $Target,
  [string[]] $Plugin,
  [switch] $Copy,
  [switch] $Uninstall
)
$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
if (-not $Plugin) { $Plugin = Get-ChildItem "$repoRoot/plugins" -Directory | ForEach-Object Name }
New-Item -ItemType Directory -Force -Path $Target | Out-Null
$count = 0
foreach ($p in $Plugin) {
  $skillsDir = Join-Path $repoRoot "plugins/$p/skills"
  if (-not (Test-Path $skillsDir)) { throw "no such plugin: $p" }
  foreach ($skill in Get-ChildItem $skillsDir -Directory) {
    $dest = Join-Path $Target $skill.Name
    $ours = (Test-Path $dest) -and (((Get-Item $dest).LinkType) -or (Test-Path (Join-Path $dest '.iam-agent-skills')))
    if ($Uninstall) {
      if ($ours) { Remove-Item $dest -Recurse -Force; "removed $dest"; $count++ }
      continue
    }
    if ((Test-Path $dest) -and -not $ours) { Write-Warning "skip $($skill.Name): $dest exists"; continue }
    if (Test-Path $dest) { Remove-Item $dest -Recurse -Force }
    if ($Copy) {
      Copy-Item $skill.FullName $dest -Recurse
      New-Item -ItemType File -Path (Join-Path $dest '.iam-agent-skills') | Out-Null
    } else {
      # Symlinks need Developer Mode or an elevated shell; fall back to a junction.
      try { New-Item -ItemType SymbolicLink -Path $dest -Target $skill.FullName | Out-Null }
      catch { New-Item -ItemType Junction -Path $dest -Target $skill.FullName | Out-Null }
    }
    "installed $($skill.Name) -> $dest"; $count++
  }
}
"done: $count skill(s)"
