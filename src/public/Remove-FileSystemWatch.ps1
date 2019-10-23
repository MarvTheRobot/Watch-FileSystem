function Remove-FileSystemWatch {
    [cmdletbinding()]
    param(
      [string]$SourceIdentifierPrefix = '[WatchFS]:'
    )
    
    Write-Verbose "Removing any existing event subscriptions for $sourceIdentifierPrefix"
    Get-Job | Where-Object { 
      $_.Name.StartsWith($sourceIdentifierPrefix)
    } | Remove-Job -Force
  
    Get-EventSubscriber | Where-Object { 
      $_.SourceIdentifier.StartsWith($sourceIdentifierPrefix)
    } | Unregister-Event -Force
  
    Write-Verbose "All event subscriptions for $sourceIdentifierPrefix have been removed"
}