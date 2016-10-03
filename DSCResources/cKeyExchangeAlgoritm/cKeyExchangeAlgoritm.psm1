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
        [ValidateSet("Diffie-Hellman","ECDH","PKCS")]
        [System.String]
        $KeyExchangeAlgoritm,

        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure
    )
    
    $returnValue = @{
    KeyExchangeAlgoritm = [System.String]$KeyExchangeAlgoritm
    Ensure = [System.String](Test-SchannelKeyExchangeAlgorithm -algorithm $KeyExchangeAlgoritm -enable ($Ensure -eq "Present"))
    }

    $returnValue
    
}


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet("Diffie-Hellman","ECDH","PKCS")]
        [System.String]
        $KeyExchangeAlgoritm,

        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure
    )

    if($Ensure -eq "Present")
    {
        Write-Verbose -Message ($LocalizedData.ItemEnable -f 'KeyExchangeAlgoritm', $KeyExchangeAlgoritm)
        Enable-SchannelKeyExchangeAlgorithm -algorithm $KeyExchangeAlgoritm
    }    
    else
    {
        Write-Verbose -Message ($LocalizedData.ItemDisable -f 'KeyExchangeAlgoritm', $KeyExchangeAlgoritm)
        Disable-SchannelKeyExchangeAlgorithm -algorithm $KeyExchangeAlgoritm
    }


}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet("Diffie-Hellman","ECDH","PKCS")]
        [System.String]
        $KeyExchangeAlgoritm,

        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure
    )

    $Compliant = $true
    Write-Verbose -Message ($LocalizedData.ItemTest -f 'KeyExchangeAlgoritm', $KeyExchangeAlgoritm)
    if(-not (Test-SchannelKeyExchangeAlgorithm -algorithm $KeyExchangeAlgoritm -enable ($Ensure -eq "Present")))
    {
        $Compliant = $false
    }    
            if($Compliant)
    {
        Write-Verbose -Message ($LocalizedData.ItemCompliant -f 'KeyExchangeAlgoritm', $KeyExchangeAlgoritm)
    }
    else
    {
        Write-Verbose -Message ($LocalizedData.ItemNotCompliant -f 'KeyExchangeAlgoritm', $KeyExchangeAlgoritm)
    }
    return $Compliant
}


Export-ModuleMember -Function *-TargetResource

