param(
  [string] $RepoRoot = (Get-Location).Path
)

$gitDir = Join-Path $RepoRoot ".git"
if (-not (Test-Path $gitDir)) {
  Write-Error ".git not found. Run 'git init' first (or run this inside a git repo)."
  exit 2
}

$src = Join-Path $RepoRoot ".githooks\pre-commit"
if (-not (Test-Path $src)) {
  Write-Error "Hook template not found at $src"
  exit 3
}

$dstDir = Join-Path $gitDir "hooks"
$dst = Join-Path $dstDir "pre-commit"

New-Item -ItemType Directory -Force -Path $dstDir | Out-Null
Copy-Item -Force $src $dst

Write-Host "Installed pre-commit hook to $dst"
Write-Host "Note: If you're using Git Bash, ensure LF line endings and executable bit as needed."

