<#
    .SYNOPSIS
        Get image versions to use for deployment of Azure virtual machines

    .DESCRIPTION
        The script is used to get previous image versions that can be used when provisoning Azure virtual machines. By default
        the script will get the image versions 2 months from the current date/time. This can be used to ensure there are meaningful
        updates for PoC exercises.

    .PARAMETER locationName
        There can be differnces between regions. This parameter is used to specify the region to get the image versions from.
        This should be the region that the virtual machines will be deployed to.
    
    .NOTES 
        Copy the respective image versions if you do not want to use the latest one. Replace latest with the 
        corresponding version  during the ARM template deployment.

#>

param(

    $locationName = 'southcentralus'
)
$imageSettings = @(
    @{
        imageFilter = (Get-Date).AddMonths(-2).ToString('yyMM')
        skus =  @('2019-Datacenter','2016-Datacenter', '2012-R2-Datacenter')
        pubName = 'MicrosoftWindowsServer'
        offerName = 'WindowsServer'

    },
    @{
        imageFilter = (Get-Date).AddMonths(-2).ToString('yyyyMM')
        skus = @('18.04-LTS','16.04-LTS')
        pubName = 'Canonical'
        offerName = 'UbuntuServer'
    }
)

 $imageSettings[0].skus | `
 % { Get-AzVMImage -Location $locationName -PublisherName $imageSettings[0].pubName -Offer $imageSettings[0].offerName -Sku $_ | ? {$_.Version -match $imageSettings[0].imageFilter}  | Select Skus, Version  }


 <#
 $imageSettings[1].skus | `
 % {Get-AzVMImage -Location $locationName -PublisherName $imageSettings[1].pubName -Offer $imageSettings[1].offerName -Sku $_ | ? {$_.Version -match $imageSettings[1].imageFilter}  | Select Skus, Version -Last 1 }
#>