param(
	[Parameter(Mandatory=$false)]
    [string]$SourceDir
)
$parent = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
. "$parent/utility/Get-CommentBasedHelp.ps1"

#this is wrong and actually defaulting to the env variable as it's not being called with a 'sourceDir'
#change this to a mandatory call with a properties file
if($null -eq $SourceDir -OR [string]::IsNullOrEmpty($SourceDir)){
	if($env:BUILD_SOURCEDIRECTORY) {$sourceDir = $env:BUILD_SOURCEDIRECTORY}
	else {$SourceDir = Split-Path -Parent $PSScriptRoot}
}

$sourceFiles = Get-ChildItem (Join-Path -Path $sourceDir -ChildPath 'src') -Include "*.psm1", "*.ps1", "*.psd1" -Exclude "*.tests.ps1" -Recurse
 
Describe 'Standards - Testing development project against team standards ' {
	$scriptFiles = $sourceFiles | where-object {$_.Extension -eq '.ps1'}

	foreach($scriptFile in $scriptFiles){
		Context "Testing '$($scriptFile.Name)' for standards compliance" {		
			It "has an associated test file" {
				$testFilePath = $scriptFile.FullName -Replace '.ps1', '.Tests.ps1'
				Test-Path -Path $testFilePath | should -BeTrue -Because "all functions should have associated tests"
			}

			It "is a single file function or class" {
				#arrange
                $parseErr, $tokens, $parsed = $null
                [string]$keyword

				$parsed=[System.Management.Automation.Language.Parser]::ParseFile($scriptFile.Fullname,[ref]$tokens,[ref]$parseErr)
                
                $commandName = $scriptFile.BaseName
                if($commandName.Contains('.Class')){
                    $commandName = $commandName.Replace('.Class','')
                    $keyword = 'class'
                }else{
                    $keyword = 'function'
                }

				#act
				$extent = $parsed.Extent.ToString() -Split '\n'
				$commandKeyword = $extent | select-string -pattern "$keyword $commandName\s"

				#assert
				$parseErr             | should -BeNullOrEmpty
				$commandKeyword.Count | should -BeExactly 1 -Because "there should only be a single $keyword within each file"
				$commandKeyword       | should -Match "^$keyword $commandName\s" -Because "the $keyword name should match the file name it is in"
			}

			Context "Testing '$($scriptFile.Name)' for Comment Based Help" {
				$cbh = Get-CommentBasedHelp -Path $scriptFile.FullName

				It "should have defined a SYNOPSIS" {
					$cbh.SYNOPSIS | Should -Not -BeNullOrEmpty	
				}
			}
		}
	}
}