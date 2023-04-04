#Requires -Version 3.0 -Modules ActiveDirectory
function Test-ADPasswords {

    <#
    .DESCRIPTION
        Test one or more Active Directory accounts for a specific password.
    .PARAMETER Username
        The username for the Active Directory account.
    .PARAMETER Password
        The password to test for.
    .PARAMETER ComputerName
        The server or computer name that has PowerShell remoting enabled.
    .PARAMETER InputObject
        Accepts the output of Get-ADUser
    .EXAMPLE
        Test-ADPasswords -username Administrator -password asdF1234 -computername Server01
    .EXAMPLE
        Get-ADUser -Filter * -SearchBase 'OU=<OU-NAME>,OU=Test,DC=TestDC,DC=com' | Test-ADPasswords -password asdF1234 -computername Server01    
    #>

    [CmdletBinding(DefaultParameterSetName='Parameter Set Username')]
    param(
        [Parameter(Mandatory,
                    ValueFromPipeline,
                    ValueFromPipelineByPropertyName,
                    ParameterSetName='Parameter Set Username')]
        [Alias('SamAccountName')]
        [string[]]$username,

        [Parameter(Mandatory)]
        [string]$password,

        [Parameter(Mandatory)]
        [string]$computername,

        [Parameter(ValueFromPipeline,
                    ParameterSetName='Parameter Set InputObject')]
        [Microsoft.ActiveDirectory.Management.ADUser]$InputObject
    )

    BEGIN {
        $Pass = ConvertTo-SecureString $password -AsPlainText -Force

        $Params = @{
            computername = $computername
            scriptblock = {Get-Random | Out-Null}
            ErrorAction = 'SilentlyContinue'
            ErrorVariable = 'Results'
        }
    }

    PROCESS {
        if($PSBoundParameters.username)
        {
            Write-Verbose -Message 'Input received via the "username" parameter set.'
            $users = $username
        }
        elseif($PSBoundParameters.InputObject)
        {
            Write-Verbose -Message 'Input received vai the "InputObject" parameter set.'
            $users = $InputObject
        }

        foreach($user in $users)
        {
            if(-not($users.SamAccountName))
            {
                Write-Verbose -Message "Querying Active Directory for Username $(user)"
                $user = Get-ADUser -Identity $user
            }

            $Params.Credential = (New-Object Sytem.Management.Automation.PSCredential ($($user.UserPrincipalName), $Pass))

            Invoke-Command @Params

            [pscustomobject]@{
                username = $user.SamAccountName
                PasswordCorrect = 
                    switch ($Results.FullyQualifiedErrorId -replace ',.*$')
                    {
                        LogonFailure { $false; break }
                        AccessDenied { $false; break }
                        default { $true }
                    }
            }
        }
    }
}