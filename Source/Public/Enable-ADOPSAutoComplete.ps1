function Enable-ADOPSAutoComplete {
    [SkipTest('HasOrganizationParameter')]
    [CmdletBinding()]
    param ()

    begin {
        $commands = Get-Command -Name '*-ADOPS*'
        $commandsWithOrganization = $commands | Get-Command -ParameterName Organization
        $commandsWithProject = $commands | Get-Command -ParameterName Project
    }
    
    process {
        # -Organization
        Register-ArgumentCompleter -CommandName $commandsWithOrganization.Name -ParameterName Organization -ScriptBlock {
            param(
                [string]$CommandName,
                [string]$ParameterName,
                [string]$WordToComplete,
                [System.Management.Automation.Language.CommandAst]$CommandAst,
                [System.Collections.IDictionary]$FakeBoundParameters
            )
            (Get-ADOPSConnection).Keys | Where-Object { $_ -like "$WordToComplete*" }
        }

        # -Project
        Register-ArgumentCompleter -CommandName $commandsWithProject.Name -ParameterName Project -ScriptBlock {
            param(
                [string]$CommandName,
                [string]$ParameterName,
                [string]$WordToComplete,
                [System.Management.Automation.Language.CommandAst]$CommandAst,
                [System.Collections.IDictionary]$FakeBoundParameters
            )
            $names = (Get-ADOPSProject).name | Sort-Object | Where-Object { $_ -like "$("$WordToComplete".Trim("'"))*" }
            # Escape names with spaces
            $names | ForEach-Object { $_ -like '* *' ? "'$($_)'" : $_ }
        }

        # Get-ADOPSUser -Name
        Register-ArgumentCompleter -CommandName Get-ADOPSUser -ParameterName Name -ScriptBlock {
            param(
                [string]$CommandName,
                [string]$ParameterName,
                [string]$WordToComplete,
                [System.Management.Automation.Language.CommandAst]$CommandAst,
                [System.Collections.IDictionary]$FakeBoundParameters
            )
            $names = ([string]::IsNullOrEmpty($WordToComplete) ? (Get-ADOPSUser) : (Get-ADOPSUser -Name $WordToComplete.Trim("'"))) | Select-Object -Unique -ExpandProperty displayName | Sort-Object | Where-Object { $_ -like "$("$WordToComplete".Trim("'"))*" }
            # Escape names with spaces
            $names | ForEach-Object { $_ -like '* *' ? "'$($_)'" : $_ }
        }
    }
}
