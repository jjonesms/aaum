Configuration WindowsUpdateClientSettings
{

    Node WindowsUpdateSettings
    {
        Registry EnableDownloadUpdates {

            Ensure="Present"
            Key = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
            ValueName = 'AUOptions'
            ValueData = "3"
            ValueType = "Dword"
        }
     
    }
    
}