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
        Registry EnableNoAutoUpdate {

            Ensure="Present"
            Key = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
            ValueName = 'NoAutoUpdate'
            ValueData = "1"
            ValueType = "Dword"
         }
    }
    
}