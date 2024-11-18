function Mssql-Cli {
  param ([String][Parameter(Mandatory=$True)]$Server, [string][Parameter(Mandatory=$True)]$Database, [string][Parameter(Mandatory=$True)]$Query)

  if ($Server -match "mssql03") {
    $Server = Get-azKeyVaultSecret -VaultName MeaOnPrem -Name MSSQL03-SERVER -AsPlainText
    $user = Get-azKeyVaultSecret -VaultName MeaOnPrem -Name MSSQL03-USER -AsPlainText
    $pass = Get-azKeyVaultSecret -VaultName MeaOnPrem -Name MSSQL03-PASSWORD -AsPlainText
    $arguments = @{ ServerInstance = $Server; Username = $user; Password = $pass; Database = $Database; Query = $Query; TrustServerCertificate = $true }
  }
  elseif ($Server -match "mssql04") {
    $Server = Get-azKeyVaultSecret -VaultName MeaOnPrem -Name MSSQL04-SERVER -AsPlainText
    $user = Get-azKeyVaultSecret -VaultName MeaOnPrem -Name MSSQL04-USER -AsPlainText
    $pass = Get-azKeyVaultSecret -VaultName MeaOnPrem -Name MSSQL04-PASSWORD -AsPlainText
    $arguments = @{ ServerInstance = $Server; Username = $user; Password = $pass; Database = $Database; Query = $Query; TrustServerCertificate = $true }
  }
  elseif ($Server -match "azure") {
    $token = (Get-AzAccessToken -ResourceUrl https://database.windows.net -AsSecureString).Token | ConvertFrom-SecureString -AsPlainText
    $arguments = @{ ServerInstance = $env:DB_SERVER; Database = $Database; AccessToken = $token; Query = $Query }
  }
  else {
    $token = (Get-AzAccessToken -ResourceUrl https://database.windows.net -AsSecureString).Token | ConvertFrom-SecureString -AsPlainText
    $arguments = @{ ServerInstance = $Server; Database = $Database; AccessToken = $token; Query = $Query }
  }

  Invoke-SqlCmd @arguments
}

function Fps-For {
  param ([String][Parameter(Mandatory=$True)] $UtilSearchTerm)

  sqlcmd -U $env:MSSQL04_USER -P $env:MSSQL04_PASSWORD -S $env:MSSQL04_SERVER -d DataScienceMart -i /workspace/fcst-points.sql -W -v util=$UtilSearchTerm
}

function Sqlcmd-WithAuth {
  param ([String][Parameter(Mandatory=$True)]$Server, [parameter(ValueFromRemainingArguments = $true)][string[]]$Passthrough)

  if ($Server -match "mssql03") {
    $Server = Get-azKeyVaultSecret -VaultName MeaOnPrem -Name MSSQL03-SERVER -AsPlainText
    $user = Get-azKeyVaultSecret -VaultName MeaOnPrem -Name MSSQL03-USER -AsPlainText
    $pass = Get-azKeyVaultSecret -VaultName MeaOnPrem -Name MSSQL03-PASSWORD -AsPlainText
    $arguments = @("-S", $server, "-U", $user, "-P", $pass) + $Passthrough
  }
  elseif ($Server -match "mssql04") {
    $server = Get-azKeyVaultSecret -VaultName MeaOnPrem -Name MSSQL04-SERVER -AsPlainText
    $user = Get-azKeyVaultSecret -VaultName MeaOnPrem -Name MSSQL04-USER -AsPlainText
    $pass = Get-azKeyVaultSecret -VaultName MeaOnPrem -Name MSSQL04-PASSWORD -AsPlainText
    $arguments = @("-S", $server, "-U", $user, "-P", $pass) + $Passthrough
  }
  else {
    $arguments = $Passthrough
  }

  sqlcmd $arguments
}