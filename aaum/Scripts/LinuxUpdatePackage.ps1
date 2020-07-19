Configuration LinuxUpdateSettings
{
    Import-DSCResource -Module nx

    Node LinuxUpdateConfig
    {
        nxPackage unattendedUpgades
        {
            Name = "unattended-upgrades"
            Ensure = "Absent"
            PackageManager = "Apt"
        }
    }
}