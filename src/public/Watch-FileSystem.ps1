
function Watch-FileSystem {
  [cmdletbinding(ConfirmImpact='low')]
  Param(
    [Parameter(
      Mandatory=$true, 
      ValueFromPipelineByPropertyName=$true, 
      ValueFromPipeline=$true
    )]
    [ValidateScript({Test-Path $_})]
    [string]$Path,

    [string]$Filter = '*.*',
    
    [ValidateSet('Created', 'Renamed', 'Changed', 'Deleted')]
    [string[]]$EventName = 'Changed',
    
    [System.IO.NotifyFilters]$NotifyFilters = ('FileName, LastWrite'),

    [ValidateNotNullOrEmpty()]
    [scriptblock]$Action = {Write-Host $event.MessageData}
  )
  $sourceIdentifierPrefix = "[WatchFS]:"
  
  Write-Verbose
  Remove-FileSystemWatch -SourceIdentifierPrefix $sourceIdentifierPrefix

  Write-Verbose "Create new File System Watcher"
  $watcher = [System.IO.FileSystemWatcher]::new()
  $watcher.Path = $Path
  $watcher.Filter = $Filter
  $watcher.NotifyFilter = $NotifyFilters
  $watcher.EnableRaisingEvents = $true
  $watcher.IncludeSubdirectories = $true
  
  foreach($name in $EventName){
    $objectEvent = @{
      InputObject = $watcher
      EventName = $name
      SourceIdentifier = $sourceIdentifierPrefix + $name
      Action = $Action
    }
    
    Write-Verbose "Registering event subscription for $sourceIdentifierPrefix"
    Register-ObjectEvent @objectEvent -ErrorAction Stop | Out-Null
    Write-Host "[WatchFS]: Waiting for something to be $name..."
  } 
}