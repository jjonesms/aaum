
param(
   $cloudEnv = "AzureCloud"
)
Connect-AzAccount -Environment $cloudEnv

Get-AzSubscription