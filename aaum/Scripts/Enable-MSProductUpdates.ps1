$ServiceManager = (New-Object -com "Microsoft.Update.ServiceManager")
$ServiceManager.Services
$ServiceID = "7971f918-a847-4430-9279-4a52d1efe18d"
$ServiceManager.AddService2($ServiceId,7,"")


if((Get-Service -Name wuauserv).Status -eq "Running")
{

    Restart-Service -Name wuauserv -Force
}