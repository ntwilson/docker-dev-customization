Import-Module posh-git

oh-my-posh --init --shell pwsh --config ~/.config/oh-my-posh/ntwilson.omp.json | Invoke-Expression

if (Test-Path /secrets/.env) {
  import-dotenv /secrets/.env
}

if (Test-Path /secrets/.ntw.env) {
  import-dotenv /secrets/.ntw.env
}
