Import-Module posh-git
Import-Module dotenv

oh-my-posh --init --shell pwsh --config ~/.config/oh-my-posh/ntwilson.omp.json | Invoke-Expression

if (Test-Path .\.env) {
  import-dotenv
}

$env:MSSQL03_CONN = cat /git/secrets/MSSQL03_CONN
$env:MSSQL03_USER = cat /git/secrets/MSSQL03_USER
$env:MSSQL03_PASSWORD = cat /git/secrets/MSSQL03_PASSWORD

$env:MSSQL04_CONN = cat /git/secrets/MSSQL04_CONN
$env:MSSQL04_USER = cat /git/secrets/MSSQL04_USER
$env:MSSQL04_PASSWORD = cat /git/secrets/MSSQL04_PASSWORD
