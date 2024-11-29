function Mssql-Cli {
  param (
    [String][Parameter(Mandatory=$True)]$Server,
    [string][Parameter(Mandatory=$True)]$Database,
    [string]$Query,
    [string]$InputScript,
    [string]$Variable
  )

  if ($Server -match "mssql03") {
    $Server = Get-azKeyVaultSecret -VaultName MeaOnPrem -Name MSSQL03-SERVER -AsPlainText
    $user = Get-azKeyVaultSecret -VaultName MeaOnPrem -Name MSSQL03-USER -AsPlainText
    $pass = Get-azKeyVaultSecret -VaultName MeaOnPrem -Name MSSQL03-PASSWORD -AsPlainText
    $arguments = @{ ServerInstance = $Server; Username = $user; Password = $pass; Database = $Database; TrustServerCertificate = $true }
  }
  elseif ($Server -match "mssql04") {
    $Server = Get-azKeyVaultSecret -VaultName MeaOnPrem -Name MSSQL04-SERVER -AsPlainText
    $user = Get-azKeyVaultSecret -VaultName MeaOnPrem -Name MSSQL04-USER -AsPlainText
    $pass = Get-azKeyVaultSecret -VaultName MeaOnPrem -Name MSSQL04-PASSWORD -AsPlainText
    $arguments = @{ ServerInstance = $Server; Username = $user; Password = $pass; Database = $Database; TrustServerCertificate = $true }
  }
  elseif ($Server -match "azure") {
    $connStr = "Server=$env:DB_SERVER; Authentication=Active Directory Default; Database=$Database;"
    $arguments = @{ ConnectionString = $connStr }
  }
  else {
    $connStr = "Server=$Server; Authentication=Active Directory Default; Database=$Database;"
    $arguments = @{ ConnectionString = $connStr }
  }

  if ($Query) {
    $arguments.Add("Query", $Query)
  }
  elseif ($InputScript) {
    $arguments.Add("InputFile", $InputScript)
  }
  else {
    Write-Error "Must have either a Query or an InputScript provided"
  }

  if ($Variable) {
    $arguments.Add("Variable", $Variable)
  }

  Invoke-SqlCmd @arguments
}

function Mssql-CliTables {
  param (
    [String][Parameter(Mandatory=$True)]$Server,
    [string][Parameter(Mandatory=$True)]$Database
  )

  if ($Server -match "mssql03") {
    $Server = Get-azKeyVaultSecret -VaultName MeaOnPrem -Name MSSQL03-SERVER -AsPlainText
    $user = Get-azKeyVaultSecret -VaultName MeaOnPrem -Name MSSQL03-USER -AsPlainText
    $pass = Get-azKeyVaultSecret -VaultName MeaOnPrem -Name MSSQL03-PASSWORD -AsPlainText
    $arguments = @{ ServerInstance = $Server; Username = $user; Password = $pass; Database = $Database; TrustServerCertificate = $true }
  }
  elseif ($Server -match "mssql04") {
    $Server = Get-azKeyVaultSecret -VaultName MeaOnPrem -Name MSSQL04-SERVER -AsPlainText
    $user = Get-azKeyVaultSecret -VaultName MeaOnPrem -Name MSSQL04-USER -AsPlainText
    $pass = Get-azKeyVaultSecret -VaultName MeaOnPrem -Name MSSQL04-PASSWORD -AsPlainText
    $arguments = @{ ServerInstance = $Server; Username = $user; Password = $pass; Database = $Database; TrustServerCertificate = $true }
  }
  elseif ($Server -match "azure") {
    $connStr = "Server=$env:DB_SERVER; Authentication=Active Directory Default; Database=$Database;"
    $arguments = @{ ConnectionString = $connStr }
  }
  else {
    $connStr = "Server=$Server; Authentication=Active Directory Default; Database=$Database;"
    $arguments = @{ ConnectionString = $connStr }
  }

  $arguments.Add("Query", "exec sp_tables")

  Invoke-SqlCmd @arguments | Where-Object { $_.table_owner -match 'dbo' } | ForEach-Object table_name
}

function Mssql-CliIndexes {
  param (
    [String][Parameter(Mandatory=$True)]$Server,
    [string][Parameter(Mandatory=$True)]$Database,
    [string]$TableName
  )

  if ($Server -match "mssql03") {
    $Server = Get-azKeyVaultSecret -VaultName MeaOnPrem -Name MSSQL03-SERVER -AsPlainText
    $user = Get-azKeyVaultSecret -VaultName MeaOnPrem -Name MSSQL03-USER -AsPlainText
    $pass = Get-azKeyVaultSecret -VaultName MeaOnPrem -Name MSSQL03-PASSWORD -AsPlainText
    $arguments = @{ ServerInstance = $Server; Username = $user; Password = $pass; Database = $Database; TrustServerCertificate = $true }
  }
  elseif ($Server -match "mssql04") {
    $Server = Get-azKeyVaultSecret -VaultName MeaOnPrem -Name MSSQL04-SERVER -AsPlainText
    $user = Get-azKeyVaultSecret -VaultName MeaOnPrem -Name MSSQL04-USER -AsPlainText
    $pass = Get-azKeyVaultSecret -VaultName MeaOnPrem -Name MSSQL04-PASSWORD -AsPlainText
    $arguments = @{ ServerInstance = $Server; Username = $user; Password = $pass; Database = $Database; TrustServerCertificate = $true }
  }
  elseif ($Server -match "azure") {
    $connStr = "Server=$env:DB_SERVER; Authentication=Active Directory Default; Database=$Database;"
    $arguments = @{ ConnectionString = $connStr }
  }
  else {
    $connStr = "Server=$Server; Authentication=Active Directory Default; Database=$Database;"
    $arguments = @{ ConnectionString = $connStr }
  }

  $arguments.Add("Query", "exec sp_statistics $TableName")

  Invoke-SqlCmd @arguments | Select-Object -Property index_name,type,column_name,seq_in_index | Format-Table
}

function Mssql-CliFKs {
  param (
    [String][Parameter(Mandatory=$True)]$Server,
    [string][Parameter(Mandatory=$True)]$Database,
    [string]$OnTable,
    [string]$ToTable
  )

  if ($Server -match "mssql03") {
    $Server = Get-azKeyVaultSecret -VaultName MeaOnPrem -Name MSSQL03-SERVER -AsPlainText
    $user = Get-azKeyVaultSecret -VaultName MeaOnPrem -Name MSSQL03-USER -AsPlainText
    $pass = Get-azKeyVaultSecret -VaultName MeaOnPrem -Name MSSQL03-PASSWORD -AsPlainText
    $arguments = @{ ServerInstance = $Server; Username = $user; Password = $pass; Database = $Database; TrustServerCertificate = $true }
  }
  elseif ($Server -match "mssql04") {
    $Server = Get-azKeyVaultSecret -VaultName MeaOnPrem -Name MSSQL04-SERVER -AsPlainText
    $user = Get-azKeyVaultSecret -VaultName MeaOnPrem -Name MSSQL04-USER -AsPlainText
    $pass = Get-azKeyVaultSecret -VaultName MeaOnPrem -Name MSSQL04-PASSWORD -AsPlainText
    $arguments = @{ ServerInstance = $Server; Username = $user; Password = $pass; Database = $Database; TrustServerCertificate = $true }
  }
  elseif ($Server -match "azure") {
    $connStr = "Server=$env:DB_SERVER; Authentication=Active Directory Default; Database=$Database;"
    $arguments = @{ ConnectionString = $connStr }
  }
  else {
    $connStr = "Server=$Server; Authentication=Active Directory Default; Database=$Database;"
    $arguments = @{ ConnectionString = $connStr }
  }
  
  if ($OnTable) {
    $arguments.Add("Query", "exec sp_fkeys @fktable_name=$OnTable")
    Invoke-SqlCmd @arguments | Select-Object -Property fk_name,fkcolumn_name,pktable_name,pkcolumn_name,key_seq | Format-Table
  }
  else {
    $arguments.Add("Query", "exec sp_fkeys @pktable_name=$ToTable")
    Invoke-SqlCmd @arguments | Select-Object -Property fk_name,pkcolumn_name,fktable_name,fkcolumn_name,key_seq | Format-Table
  }
}

function Fps-For {
  param ([String][Parameter(Mandatory=$True)] $UtilSearchTerm)
  $Server = Get-azKeyVaultSecret -VaultName MeaOnPrem -Name MSSQL04-SERVER -AsPlainText
  $user = Get-azKeyVaultSecret -VaultName MeaOnPrem -Name MSSQL04-USER -AsPlainText
  $pass = Get-azKeyVaultSecret -VaultName MeaOnPrem -Name MSSQL04-PASSWORD -AsPlainText

  $results = sqlcmd -U $user -P $pass -S $Server -d DataScienceMart -i "$PSScriptRoot/fcst-points.sql" -W -s ',' -v util=$UtilSearchTerm

  $parsed = @($results | Select-Object -First 1) + @($results | Select-Object -Skip 2)
  $parsed | ConvertFrom-Csv | Format-Table
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

function beep {
  [Console]::Beep()
}
