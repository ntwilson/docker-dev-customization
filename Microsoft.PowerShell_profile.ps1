Import-Module posh-git

oh-my-posh --init --shell pwsh --config ~/.config/oh-my-posh/ntwilson.omp.json | Invoke-Expression

if (Test-Path .\.env) {
  import-dotenv
}
