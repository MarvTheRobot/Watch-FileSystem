@{
    PSDependOptions = @{
        Target = "../lib" # I want all my dependencies installed here
        AddToPath = $True            # I want to prepend project to $ENV:Path and $ENV:PSModulePath
    }

    'Psake'            = 'latest'
    'PSScriptAnalyzer' = 'latest'
    'Pester'           = 'latest'
    'BuildHelpers'     = 'latest'
}