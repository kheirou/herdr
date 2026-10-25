param([switch]$Changed)
$ErrorActionPreference = 'Stop'
function Step($cmd) { Write-Host "==> $cmd"; Invoke-Expression $cmd; if ($LASTEXITCODE) { exit $LASTEXITCODE } }
Step 'cargo fmt --check'
Step 'cargo clippy --all-targets --locked -- -D warnings'
$filters = @()
if ($Changed) {
  $files = git diff --name-only origin/master...HEAD
  if ($files | Where-Object { $_ -notmatch '^(src/.+\.rs|mise\.toml|scripts/dev-ci\.ps1)$' }) { $Changed = $false }
  else { $filters = $files | Where-Object { $_ -like 'src/*' } | ForEach-Object { ($_ -replace '^src/|\.rs$|/mod$', '') -replace '/', '::' } }
}
Step "cargo test -p herdr --bin herdr --locked -- $($filters -join ' ')"
