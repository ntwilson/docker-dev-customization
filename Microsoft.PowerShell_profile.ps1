Import-Module posh-git

oh-my-posh --init --shell pwsh --config ~/.config/oh-my-posh/ntwilson.omp.json | Invoke-Expression

if (Test-Path .\.env) {
  import-dotenv
}

$env:MSSQL03_SERVER = cat /secrets/MSSQL03_SERVER
$env:MSSQL03_USER = cat /secrets/MSSQL03_USER
$env:MSSQL03_PASSWORD = cat /secrets/MSSQL03_PASSWORD

$env:MSSQL04_SERVER = cat /secrets/MSSQL04_SERVER
$env:MSSQL04_USER = cat /secrets/MSSQL04_USER
$env:MSSQL04_PASSWORD = cat /secrets/MSSQL04_PASSWORD
