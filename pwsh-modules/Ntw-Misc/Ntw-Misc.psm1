$script:MssqlCredentialCache = @{}

function Get-MssqlArguments {
  param (
    [string]$Server,
    [string]$Database
  )

  if ($Server -match "mssql03") {
    if (-not $script:MssqlCredentialCache.ContainsKey("mssql03")) {
      $script:MssqlCredentialCache["mssql03"] = @{
        Server = Get-azKeyVaultSecret -VaultName MeaOnPrem -Name MSSQL03-SERVER -AsPlainText
        User   = Get-azKeyVaultSecret -VaultName MeaOnPrem -Name MSSQL03-USER -AsPlainText
      }
    }
    $creds = $script:MssqlCredentialCache["mssql03"]
    $pass = Get-azKeyVaultSecret -VaultName MeaOnPrem -Name MSSQL03-PASSWORD -AsPlainText
    return @{ ServerInstance = $creds.Server; Username = $creds.User; Password = $pass; Database = $Database; TrustServerCertificate = $true }
  } elseif ($Server -match "mssql04") {
    if (-not $script:MssqlCredentialCache.ContainsKey("mssql04")) {
      $script:MssqlCredentialCache["mssql04"] = @{
        Server = Get-azKeyVaultSecret -VaultName MeaOnPrem -Name MSSQL04-SERVER -AsPlainText
        User   = Get-azKeyVaultSecret -VaultName MeaOnPrem -Name MSSQL04-USER -AsPlainText
      }
    }
    $creds = $script:MssqlCredentialCache["mssql04"]
    $pass = Get-azKeyVaultSecret -VaultName MeaOnPrem -Name MSSQL04-PASSWORD -AsPlainText
    return @{ ServerInstance = $creds.Server; Username = $creds.User; Password = $pass; Database = $Database; TrustServerCertificate = $true }
  } elseif ($Server -match "azure" -or [string]::IsNullOrEmpty($Server)) {
    if (-not $script:MssqlCredentialCache.ContainsKey("azure")) {
      $script:MssqlCredentialCache["azure"] = @{
        Server = Get-AzKeyVaultSecret -VaultName MeaCore -Name DB-SERVER -AsPlainText
      }
    }
    $resolvedServer = $script:MssqlCredentialCache["azure"].Server
    return @{ ConnectionString = "Server=$resolvedServer; Authentication=Active Directory Default; Database=$Database;" }
  } else {
    return @{ ConnectionString = "Server=$Server; Authentication=Active Directory Default; Database=$Database;" }
  }
}

function Mssql-Cli {
  param (
    [string][Parameter(Mandatory=$True)]$Database,
    [String]$Server=$env:DB_SERVER_ADDRESS,
    [string]$Query,
    [string]$InputScript,
    [string]$Variable
  )

  $arguments = Get-MssqlArguments -Server $Server -Database $Database

  if ($Query) {
    $arguments.Add("Query", $Query)
  } elseif ($InputScript) {
    $arguments.Add("InputFile", $InputScript)
  } else {
    Write-Error "Must have either a Query or an InputScript provided"
  }

  if ($Variable) {
    $arguments.Add("Variable", $Variable)
  }

  $arguments.Add("Verbose", $true)

  Invoke-SqlCmd @arguments
}

function Mssql-CliTables {
  param (
    [string][Parameter(Mandatory=$True)]$Database,
    [String]$Server=$env:DB_SERVER_ADDRESS
  )

  $arguments = Get-MssqlArguments -Server $Server -Database $Database
  $arguments.Add("Query", "exec sp_tables")
  $arguments.Add("Verbose", $true)

  Invoke-SqlCmd @arguments | Where-Object { $_.table_owner -match 'dbo' } | ForEach-Object table_name
}

function Mssql-CliIndexes {
  param (
    [string][Parameter(Mandatory=$True)]$Database,
    [String]$Server=$env:DB_SERVER_ADDRESS,
    [string]$TableName
  )

  $arguments = Get-MssqlArguments -Server $Server -Database $Database
  $arguments.Add("Query", "exec sp_statistics $TableName")
  $arguments.Add("Verbose", $true)

  Invoke-SqlCmd @arguments | Select-Object -Property index_name,type,column_name,seq_in_index | Format-Table
}

function Mssql-CliFKs {
  param (
    [string][Parameter(Mandatory=$True)]$Database,
    [String]$Server=$env:DB_SERVER_ADDRESS,
    [string]$OnTable,
    [string]$ToTable
  )

  $arguments = Get-MssqlArguments -Server $Server -Database $Database
  $arguments.Add("Verbose", $true)

  if ($OnTable) {
    $arguments.Add("Query", "exec sp_fkeys @fktable_name=$OnTable")
    Invoke-SqlCmd @arguments | Select-Object -Property fk_name,fkcolumn_name,pktable_name,pkcolumn_name,key_seq | Format-Table
  } else {
    $arguments.Add("Query", "exec sp_fkeys @pktable_name=$ToTable")
    Invoke-SqlCmd @arguments | Select-Object -Property fk_name,pkcolumn_name,fktable_name,fkcolumn_name,key_seq | Format-Table
  }
}

function Fps-For {
  param ([String][Parameter(Mandatory=$True)] $UtilSearchTerm)
  $results = sqlcmd -S $env:DB_SERVER_ADDRESS -d Hub -G -i "$PSScriptRoot/fcst-points.sql" -W -s ',' -v util=$UtilSearchTerm

  $parsed = @($results | Select-Object -First 1) + @($results | Select-Object -Skip 2)
  $parsed | ConvertFrom-Csv | Format-Table
}

function Sqlcmd-WithAuth {
  param ([String]$Server=$env:DB_SERVER_ADDRESS, [parameter(ValueFromRemainingArguments = $true)][string[]]$Passthrough)

  if ($Server -match "mssql03") {
    if (-not $script:MssqlCredentialCache.ContainsKey("mssql03")) {
      $script:MssqlCredentialCache["mssql03"] = @{
        Server = Get-azKeyVaultSecret -VaultName MeaOnPrem -Name MSSQL03-SERVER -AsPlainText
        User   = Get-azKeyVaultSecret -VaultName MeaOnPrem -Name MSSQL03-USER -AsPlainText
      }
    }
    $creds = $script:MssqlCredentialCache["mssql03"]
    $pass = Get-azKeyVaultSecret -VaultName MeaOnPrem -Name MSSQL03-PASSWORD -AsPlainText
    $arguments = @("-S", $creds.Server, "-U", $creds.User, "-P", $pass) + $Passthrough
  } elseif ($Server -match "mssql04") {
    if (-not $script:MssqlCredentialCache.ContainsKey("mssql04")) {
      $script:MssqlCredentialCache["mssql04"] = @{
        Server = Get-azKeyVaultSecret -VaultName MeaOnPrem -Name MSSQL04-SERVER -AsPlainText
        User   = Get-azKeyVaultSecret -VaultName MeaOnPrem -Name MSSQL04-USER -AsPlainText
      }
    }
    $creds = $script:MssqlCredentialCache["mssql04"]
    $pass = Get-azKeyVaultSecret -VaultName MeaOnPrem -Name MSSQL04-PASSWORD -AsPlainText
    $arguments = @("-S", $creds.Server, "-U", $creds.User, "-P", $pass) + $Passthrough
  } else {
    $arguments = $Passthrough
  }

  sqlcmd $arguments
}

function beep {
  [Console]::Beep()
}
