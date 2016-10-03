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


    $returnValue = @{
    Hash = [System.String]$Hash
    Ensure = [System.String](Test-SchannelHash -hash $Hash -enable ($Ensure -eq "Present"))
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

    if($Ensure -eq "Present")
    {
        Write-Verbose -Message ($LocalizedData.ItemEnable -f 'Hash', $Hash)
        Enable-SchannelHash -hash $Hash
    }    
    else
    {
        Write-Verbose -Message ($LocalizedData.ItemDisable -f 'Hash', $Hash)
        Disable-SchannelHash -hash $Hash
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

    $Compliant = $true
    Write-Verbose -Message ($LocalizedData.ItemTest-f 'Hash', $Hash)
    if(-not (Test-SchannelHash -hash $Hash -enable ($Ensure -eq "Present")))
    {
        $Compliant = $false
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

