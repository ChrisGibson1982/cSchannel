# Load the Helper Module 
Import-Module -Name "$PSScriptRoot\..\Helper.psm1" 

# Localized messages
data LocalizedData
{
    # culture="en-US"
    ConvertFrom-StringData -StringData @'
        ProtocolNotCompliant           = Protocol {0} not compliant.
        ProtocolCompliant              = Protocol {0} compliant.
        ItemTest                       = Testing {0} {1}
        ItemEnable                     = Enabling {0} {1}
        ItemDisable                    = Disabling {0} {1}
        ItemNotCompliant               = {0} {1} not compliant.
        ItemCompliant                  = {0} {1} compliant.
       
'@
}

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet("MD5","SHA","SHA256","SHA384","SHA512")]
        [System.String]
        $Hash,

        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure
    )
    
    $RootKey = 'HKLM:SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Hashes'
    $Key = $RootKey + "\" + $Hash 
    if(Test-SchannelItem -itemKey $Key -enable ($Ensure -eq "Present"))
    {
        $Result = "Present" 
    }
    else
    {
        $Result = "Absent" 
    }
    
    $returnValue = @{
    Hash = [System.String]$Hash
    Ensure = [System.String]$Result
    }

    $returnValue
    
}


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet("MD5","SHA","SHA256","SHA384","SHA512")]
        [System.String]
        $Hash,

        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure
    )
    
    $RootKey = 'HKLM:SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Hashes'
    $Key = $RootKey + "\" + $Hash 

    if($Ensure -eq "Present")
    {
        Write-Verbose -Message ($LocalizedData.ItemEnable -f 'Hash', $Hash)
        Switch-SchannelItem -itemKey $Key -enable $true
    }    
    else
    {
        Write-Verbose -Message ($LocalizedData.ItemDisable -f 'Hash', $Hash)
        Switch-SchannelItem -itemKey $Key -enable $false
    }

}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet("MD5","SHA","SHA256","SHA384","SHA512")]
        [System.String]
        $Hash,

        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure
    )
    $RootKey = 'HKLM:SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Hashes'
    $Key = $RootKey + "\" + $Hash 
    $currentHash = Get-TargetResource @PSBoundParameters
    $Compliant = $false

    $ErrorActionPreference = "SilentlyContinue"
    Write-Verbose -Message ($LocalizedData.ItemTest -f 'Cipher', $Cipher)
    if($currentHash.Ensure -eq $Ensure -and (Get-ItemProperty -Path $Key -Name Enabled))
    {
        $Compliant = $true
    }

    if($Compliant)
    {
        Write-Verbose -Message ($LocalizedData.ItemCompliant -f 'Hash', $Hash)
    }
    else
    {
        Write-Verbose -Message ($LocalizedData.ItemNotCompliant -f 'Hash', $Hash)
    }
           
    return $Compliant
}


Export-ModuleMember -Function *-TargetResource

