# Introduction 

Watch-FileSystem is a _very_ quick module to create a .net file system watcher.  

The idea a that you can watch a chosen path for events (created, deleted, renamed, changed)
 and have a custom scriptblock execute.  

A simple use case for this is executing Pester tests when you change a file, similar to dotnet watch.

- [ ] MVP Met
  - [x] Can watch a chosen path for created, deleted, renamed, changed events
  - [x] Can execute custom code when events are raised
  - [ ] Can execute Pester tests on a directory when events are raised

## Build

./build/build.ps1 -BuildFile ./build/build.psake.ps1 -DependencyFile ./build/requirements.psd1 -DependencyStor ./lib -TaskList Build -Boostrap`

This will: 

- download all modules listed in `./build/requirements.psd1` using PSDepend, storing them in `lib` under the project root
- 'compile' the module files into a `Watch-FileSystem.psm1` module file
- create a `Watch-FileSystem.psd` module manifes

## Using

````powershell

cd ./buildoutput
Import-Module Watch-FileSystem

Watch-FileSystem -Path 'mtr/scratch' -Action {
    $changedItem = $event.SourceEventArgs.FullPath
    $changeType  = $event.SourceEventArgs.ChangeType
    $message = "[WatchFS] '$changedItem' [$changeType]."
    Write-Host $message -ForegroundColor Yellow
    Write-Host "[WatchFS]...waiting for something else to be [$changeType]..." -ForegroundColor Gray
} -Filter "*.ps1" -EventName Renamed, Changed

```  
