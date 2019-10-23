param(
	[Parameter(Mandatory=$false)]
    [string]$SourceDir
)

if($null -eq $SourceDir -OR [string]::IsNullOrEmpty($SourceDir)){
	if($env:BUILD_SOURCEDIRECTORY) {$sourceDir = $env:BUILD_SOURCEDIRECTORY}
	else {$SourceDir = Split-Path -Parent $PSScriptRoot}
}

$sourceFiles = Get-ChildItem (Join-Path -Path $sourceDir -ChildPath 'src') -Include "*.psm1", "*.ps1", "*.psd1" -Exclude "*.tests.ps1" -Recurse
 
Describe 'Linting - Testing all scripts and modules against the Script Analyzer Rules' {
	Context "Checking files to test exist and Invoke-ScriptAnalyzer cmdLet is available" {
		It "Checking files exist to test." {
			$sourceFiles.count | Should Not Be 0
		}

		It "Checking Invoke-ScriptAnalyzer exists." {
            $cmd = Get-Command Invoke-ScriptAnalyzer -ErrorAction Stop  
            $cmd | Should -Not -Be $null -Because 'Invoke-ScriptAnalyzer needs to be installed for subsequent tests'
		}
	}
 
	$scriptAnalyzerRules = Get-ScriptAnalyzerRule
 
	foreach ($sourceFile in $sourceFiles) {
		switch -wildCard ($sourceFile) { 
			'*.ps1'  { $typeTesting = 'Script' } 
			'*.psm1' { $typeTesting = 'Module' } 
			'*.psd1' { $typeTesting = 'Manifest' } 
		}
 
		Context "Checking $typeTesting - $($sourceFile) - has no Script Analyzer Errors" {
			foreach ($scriptAnalyzerRule in $scriptAnalyzerRules) {
				It "Script Analyzer Rule $scriptAnalyzerRule" {
					$failures = (Invoke-ScriptAnalyzer -Path $sourceFile -IncludeRule $scriptAnalyzerRule) | where-object {$_.Severity -eq "Error"}
					$failures.Count | Should Be 0
				}
			}
        }
	}
}