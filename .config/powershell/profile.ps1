##################################
# AllPlatforms-AllHosts Settings #
##################################

#
# Environment variables
#

## Add ~/bin/ to the PATH
$private:binPath = Join-Path $HOME bin
if (!$env:PATH.Contains($private:binPath)) {
    $env:PATH = "$private:binPath$([System.IO.Path]::PathSeparator)$env:PATH"
}
$private:binPath = Join-Path $HOME .local bin
if (!$env:PATH.Contains($private:binPath)) {
    $env:PATH = "$private:binPath$([System.IO.Path]::PathSeparator)$env:PATH"
}
Remove-Variable binPath
# $env:PATH -split [System.IO.Path]::PathSeparator

#
# Global variables
#

$global:DotRoot = "$env:OneDrive\dotfiles"

$global:Platform = if ($IsWindows) {
    'windows'
} elseif ($IsLinux) {
    'linux'
} elseif ($IsMacOS) {
    'macos'
}

if ($PSVersionTable.PSVersion.Major -gt 5) {
    $global:Utf8Encoding = 'utf8NoBom'
    $global:ShiftJisEncoding = 'oem'
    $global:Encoding = $global:utf8Encoding
} else {
    $global:Utf8Encoding = 'UTF8'  # with BOM
    $global:ShiftJisEncoding = 'Default'
    $global:Encoding = $global:ShiftJisEncoding
}

# Init load flag
$global:LoadedProfiles = @()

#
# Local variables
#

$scriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { "$DotRoot/.config/powershell" }

$setPSReadLineOptionParams = @{
    BellStyle                     = 'None'
    EditMode                      = 'Emacs'
    HistoryNoDuplicates           = $true
    # HistorySavePath:default     = "$env:AppData\Microsoft\Windows\PowerShell\PSReadLine\$($Host.Name)_history.txt"
    HistorySavePath               = "$env:OneDrive/.local/share/powershell/PSReadLine/PSHistory.txt"
    HistorySaveStyle              = 'SaveIncrementally'  # 'SaveIncrementally', 'SaveAtExit'
    HistorySearchCursorMovesToEnd = $true
    MaximumHistoryCount           = 1000000
}

#
# Functions
#

function Import-ScriptAsFunction { param ([Parameter(Mandatory)] [string] $Path) Invoke-Expression "function global:$((Get-Item $Path).BaseName) {`n`n$(Get-Content -Raw $Path)`n`n}" }

# PredictionSource = 'History'
if ($PSVersionTable.PSVersion -ge '7.2' -and (Get-Module PSReadline).Version -ge '2.2.2') {
    # Install-Module CompletionPredictor
    Import-Module CompletionPredictor
    $setPSReadLineOptionParams.PredictionSource = 'HistoryAndPlugin'
}

Set-PSReadLineOption @setPSReadLineOptionParams

# source history managemant setting
#. $PSScriptRoot\profile.PSReadLine.ps1

## alias functions
function q() { exit }

### aliases
#Set-Alias -Name touch -Value New-Item

## starship
if (Get-Command starship -ErrorAction SilentlyContinue) {
    $env:STARSHIP_CONFIG = "$DotRoot/.config/starship.toml"
    $startshipInitDir = Join-Path $scriptRoot $Platform
    $startshipInitPath = Join-Path $startshipInitDir startship-init.ps1
    function Update-StartShipInitScript {
        starship init powershell --print-full-init | Out-File -Encoding $Encoding $startshipInitPath
    }

    if (!(Test-Path $startshipInitPath)) {
        New-Item -ItemType Directory $startshipInitDir -Force >$null
        Update-StartShipInitScript
    }
    function Initialize-StartShip {
        . $startshipInitPath
    }
    Initialize-StartShip
}

# /opt/homebrew/bin/brew shellenv
# [System.Environment]::SetEnvironmentVariable('HOMEBREW_PREFIX', '/opt/homebrew', [System.EnvironmentVariableTarget]::Process)
# [System.Environment]::SetEnvironmentVariable('HOMEBREW_CELLAR', '/opt/homebrew/Cellar', [System.EnvironmentVariableTarget]::Process)
# [System.Environment]::SetEnvironmentVariable('HOMEBREW_REPOSITORY', '/opt/homebrew', [System.EnvironmentVariableTarget]::Process)
# [System.Environment]::SetEnvironmentVariable('PATH', $('/opt/homebrew/bin:/opt/homebrew/sbin:' + $env:PATH), [System.EnvironmentVariableTarget]::Process)
# [System.Environment]::SetEnvironmentVariable('MANPATH', $('/opt/homebrew/share/man' + $(if (${ENV:MANPATH}) { ':' + ${ENV:MANPATH} }) + ':'), [System.EnvironmentVariableTarget]::Process)
# [System.Environment]::SetEnvironmentVariable('INFOPATH', $('/opt/homebrew/share/info' + $(if (${ENV:INFOPATH}) { ':' + ${ENV:INFOPATH} })), [System.EnvironmentVariableTarget]::Process)

<#
function pacs {
    param (
        [string] $SubCommand
    )

    switch ($SubCommand) {
        'init' { Write-Host 'Initializing repository...' }
        'add' { Write-Host 'Adding files...' }
        'commit' { Write-Host 'Committing changes...' }
        'branch' { Write-Host 'Working with branches...' }
        default { Write-Host 'Unknown subcommand. Please use one of the following: init, add, commit, branch' }
    }
}

Register-ArgumentCompleter -CommandName pacs -ParameterName SubCommand -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

    $subCommands = 'init', 'add', 'commit', 'branch'
    $filteredSubCommands = $subCommands | Where-Object { $_ -like "$wordToComplete*" }

    foreach ($subCommand in $filteredSubCommands) {
        $completionText = $subCommand
        $tooltip = "$subCommand subcommand"
        New-CompletionResult -CompletionText $completionText -ToolTip $tooltip -Type ParameterValue
    }
}
#>

# function ChangeUserShellFolders {
#     <#
#     .LINK
#         https://answers.microsoft.com/ja-jp/windows/forum/all/onedrive%E4%BB%A5%E4%B8%8B%E3%81%AE%E3%83%91/64475209-7211-4c53-a88b-a1358f14dee5
#     #>
#     $path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'
#     $userShellFolders = Get-ItemProperty -Path $path

#     # show current settings
#     $userShellFolders

#     switch ($userShellFolders.PSObject.Properties) {
#         { $_.Value -match 'ドキュメント' } { Set-ItemProperty -Path $path -Name $_.Name -Value $_.Value.Replace('ドキュメント', 'Documents') -PassThru }
#         { $_.Value -match 'デスクトップ' } { Set-ItemProperty -Path $path -Name $_.Name -Value $_.Value.Replace('デスクトップ', 'Desktop') -PassThru }
#         { $_.Value -match '画像' } { Set-ItemProperty -Path $path -Name $_.Name -Value $_.Value.Replace('画像', 'Pictures') -PassThru }
#     }
# }

# function Install-ModuleToDirectory {
#     <#
#     .LINK
#         https://stackoverflow.com/a/52738820
#     #>
#     [CmdletBinding()]
#     param (
#         # $Name = 'powershell-yaml'
#         [Parameter(Mandatory)]
#         [ValidateNotNullOrEmpty()]
#         $Name
#         ,
#         [ValidateNotNullOrEmpty()]
#         [ValidateScript({ Test-Path $_ })]
#         $Destination = $global:CloudPSModulePath
#     )

#     # Is the module already installed?
#     if (-not (Test-Path (Join-Path $Destination $Name))) {
#         if (-not (Test-Path $Destination)) {
#             New-Item -ItemType Directory $Destination >$null
#         }
#         # Install the module to the custom destination.
#         Find-Module -Name $Name -Repository PSGallery | Save-Module -Path $Destination
#     }
# }

#
# Dot-source
#

# Load platform-specific profile
if (Test-Path "$scriptRoot/$Platform/profile.ps1") {
    . "$scriptRoot/$Platform/profile.ps1"
}

# Load host-specific profile
$profileFilename = $PROFILE.CurrentUserCurrentHost | Split-Path -Leaf
if (Test-Path "$scriptRoot/$profileFilename") {
    . "$scriptRoot/$profileFilename"
}
