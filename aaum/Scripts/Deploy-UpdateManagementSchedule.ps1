<#
    .SYNOPSIS
        Deploy an update management schedule for Windows or Linux

    .DESCRIPTION
        This script is intended to demonstrate how to create a scheudle to deploy software updates using the 
        Update Management solution. This is a one time schedule that will be kicked off several minutes from the time of deployment.
        A predifined scoped is configured to look at all virtual machines in a subscription that have the POC-AAUM-Lifecycle tag
        set to DevTEST. All update classifications are selected by default to ensure at least one update gets installed.


    .PARAMETER automationAccountName
        The automation account used during the PoC exercise
    .PARAMETER rgName
        Resource group name for the Automation Account
    .PARAMETER minutesFromNow
        Determines when the update deployment will run after it is created. By default it will run 45 mintues
        from deployment of the schedule
    .PARAMETER deployOS
        Determines which operating system type the schedule is deployed for. The default is Windows.
        Specify Linux if you want to deploy a schedule for Linux

    .NOTES
        In order to create the schedule, the following cmdlets are used:

        New-AzAutomationSchedule - Create the schedule to associate with the deployment
        New-AzAutomationUpdateManagementAzureQuery - Create the scope for the virtual machines to be dynamically added to the deployment
        New-AzAutomationSoftwareUpdateConfiguration - Deploy the configiuration for the deployment to Update Managment

        https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/manage/azure-server-management/update-schedules
        https://docs.microsoft.com/en-us/powershell/module/az.automation/new-azautomationsoftwareupdateconfiguration?view=azps-3.8.0
        https://docs.microsoft.com/en-us/powershell/module/az.automation/new-azautomationupdatemanagementazurequery?view=azps-3.8.0
        https://docs.microsoft.com/en-us/powershell/module/az.automation/new-azautomationschedule?view=azps-3.8.0        


#>

[CmdletBinding()]
param(
    [string]$automationAccountName,
    [string]$rgName,
    [int]$minutesFromNow = 45,
    [string]$deployOS = 'Windows'
)

$subscriptionId = (Get-AzContext).Subscription.Id

# used to create a unique schedule each time
$deployTime = Get-Date -Format MMddhhmmss

#name of the automation schedule to be create that will kick-off the deployment
$scheduleName = "PoC_$($deployOS)_$($deployTime)_OneTime_Schedule"

#Runbook to kick off before software update process
$preScript = 'UpdateManagement-TurnOnVms'
#Runbook to kick off post software update process 
$postScript = 'UpdateManagement-TurnOffVms'

#tag to filter deployment to the DevTest lifecycle
$envTag = @{"POC-AAUM-Lifecycle"= @("DevTest")}

#subscription level scope for deployment
$queryScope = @(
    "/subscriptions/$subscriptionId")

$TimeZone = ([System.TimeZoneInfo]::Local).Id
$startTime = (get-date).AddMinutes($minutesFromNow).ToString("HH:mm")

#Create scope to determine which virtual machines will be included in the deployment
$dynamicGroupQuery = New-AzAutomationUpdateManagementAzureQuery -ResourceGroupName $rgName  -AutomationAccountName $automationAccountName -Scope $queryScope -Tag $envTag -Verbose
$AzureQueries = @($dynamicGroupQuery)

$schedule = New-AzAutomationSchedule -Name $scheduleName -TimeZone $TimeZone -AutomationAccountName $automationAccountName -StartTime $startTime -OneTime -ResourceGroupName $rgName -ForUpdateConfiguration -Verbose


if($deployOS -match 'Windows'){
    
    #run for creating a schedule for Windows
    New-AzAutomationSoftwareUpdateConfiguration `
    -ResourceGroupName $rgName `
    -AutomationAccountName $automationAccountName `
    -Schedule $schedule `
    -Windows `
    -Duration (New-TimeSpan -Hours 2) `
    -AzureQuery $AzureQueries `
    -IncludedUpdateClassification Critical, Security, UpdateRollup, FeaturePack, ServicePack, Definition, Tools, Updates `
    -PreTaskRunbookName $preScript `
    -PostTaskRunbookName $postScript `
    -Verbose
   
}
if($deployOS -match 'Linux'){

    #run for creating a schedule for Linux 
    New-AzAutomationSoftwareUpdateConfiguration `
    -ResourceGroupName $rgName `
    -AutomationAccountName $automationAccountName `
    -Schedule $schedule `
    -Linux `
    -IncludedPackageClassification Critical, Security, Other `
    -Duration (New-TimeSpan -Hours 2) `
    -AzureQuery $AzureQueries `
    -PreTaskRunbookName $preScript `
    -PostTaskRunbookName $postScript `
    -Verbose
}


