[cmdletbinding()]
param(
    [ValidateScript({Test-Path $_})]
    [string]$BuildFile       = "$PsScriptRoot/build.psake.ps1",
    [ValidateScript({Test-Path $_})]
    [string]$DependencyFile  = "$PsScriptRoot/requirements.psd1",

    [string]$DependencyStore = "$(Split-Path -Parent $PsScriptRoot)/lib",
    [string]$ProjectRoot     = "$(Split-Path -Parent $PsScriptRoot)",
    [switch]$Bootstrap,
    [switch]$SkipDependencyCheck,
    [string[]]$TaskList = 'Build'
)

Write-Host "-> Entering Build Controller (build.ps1)"
$BuildFile = Resolve-Path $BuildFile
$DependencyFile = Resolve-Path $DependencyFile

if($Bootstrap){
    Write-Host '...Bootstrap requested, setting up NuGet and PSGallery'
    Write-Verbose "...Installing NuGet"
    Get-PackageProvider -Name NuGet -ForceBootstrap | Out-Null

    Write-Verbose "...Trusting PSGallery"
    Set-PSRepository    -Name PSGallery -InstallationPolicy Trusted
    
    Write-Verbose "...Installing PsDepend"
    Install-Module      -Name PsDepend -Scope CurrentUser -Force
    $psDepend = Get-Module -Name 'PsDepend' -ListAvailable -ErrorAction Stop
    
    if($null -ne $psDepend){
        Write-Verbose "--> Installing Dependencies"
        Invoke-PsDepend $DependencyFile -Target $DependencyStore -Force
        Write-Verbose "`n==========|DONE|=========`n`n"
    }else{
        Write-Warning "PsDepend not installed, dependencies will not be loaded"
    }
}elseif(-not($SkipDependencyCheck)){
    Invoke-PsDepend -Path $DependencyFile -Target $DependencyStore -Import -Confirm:$false
}

Write-Host "-> Setting Build Environment"
$bh = Get-Module BuildHelpers -ListAvailable
if($null -eq $bh){
    Throw "BuildHelpers is required to continue, are you sure you have the correct
    modules and they are imported? Try again with -Bootstrap to automatically download dependencies
    and add to Env:PSModulePath"
}
Set-BuildEnvironment -Path $projectRoot -Force
$buildEnvironment = Get-BuildEnvironment

<#
Write-Host "--------> BUILD ENVIRONMENT <---------"
$buildEnvironment
Write-Host "-> Getting current directory structure"
Write-Host "--------------------------------------"
(Get-ChildItem -Recurse).FullName
Write-Host "--------------------------------------"

#>
Write-Host "-> Invoking Psake with the following parameters"
Write-Host "---> BuildFile: $buildFile"
Write-Host "---> TaskList : $($TaskList -Join ',')  `n"
Write-Host "`n"

Invoke-Psake $BuildFile -TaskList $TaskList -parameters @{BuildEnvironment = $buildEnvironment}
Write-Host "<- Leaving Build Controller (build.ps1)"
exit ( [int]( -not $psake.build_success ) )