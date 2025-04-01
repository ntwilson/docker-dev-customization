Import-Module posh-git

oh-my-posh init pwsh --config ~/.config/oh-my-posh/ntwilson.omp.json | Invoke-Expression

if (Test-Path /secrets/.env) {
  import-dotenv /secrets/.env
}

if (Test-Path /secrets/.ntw.env) {
  import-dotenv /secrets/.ntw.env
}

$global:BillingCycleDataPath = "/workspace/BillingCycleData"
$global:DataScienceETLPath = "/workspace/DataScienceETL"
$global:HourlyModelTrainingPath = "/workspace/hourly-model-training"
$global:DailyModelTrainingPath = "/workspace/DailyModelTraining"
$global:GasDayFrameworkPath = "/workspace/GasDayFramework"
$global:WebPlatformPath = "/workspace/WebPlatform"
$global:WebDatabasePopulatorPath = "/workspace/WebDatabasePopulator"
$global:QADataTransferPath = "/workspace/QADataTransfer"
$global:MeaCorePath = "/workspace/MEA.Core"
$global:MeaSqlHydraPath = "/workspace/MEA.SqlHydra"
$global:MeaSchemasPath = "/workspace/MEA.Schemas"
$global:GasDayIOPath = "/workspace/GasDay.IO"
