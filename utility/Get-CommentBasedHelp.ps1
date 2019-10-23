function Get-CommentBasedHelp {
    [cmdletbinding()]
    param(
        [Parameter(ParameterSetName='ByObject')]
        [string]$Content,

        [Parameter(ParameterSetName='ByFile')]
        [Alias('Path')]
        [ValidateScript({
            Test-Path $_
        })]
        [string]$ContentPath
    )

    if($PSCmdlet.ParameterSetName -eq 'ByFile'){
        $Content = Get-Content -Path $ContentPath -Raw -ErrorAction Stop
    }

    $cbhStart, $cbhEnd = 0
    $splitContent = $content -Split '\n'

    for($i = 0; $i -lt $splitContent.Count -1; $i++){
        $line = $splitContent[$i].Trim()
        if($line -match '<#'){$cbhStart = $i+1}
        if($line -match '#>'){$cbhEnd = $i-1}
    }

    $comments = $splitContent[$cbhStart..$cbhEnd]

    $currentKey = ''
    $properties = @{}

    foreach ($line in $comments){
        $line = $line.Trim()

        if($line.StartsWith('<#') -or $line.StartsWith('#>')){
            #do nothing as these are comment open/close characters
        }
        elseif($line.StartsWith('.')){
                $key = $line.Replace('.','')
                $properties[$key] = 'Undefined'
                $currentKey = $key
        }
        else{
            #assume the comment is for the line comment above
            if($properties[$currentKey] -eq 'Undefined'){
                $properties[$currentKey] = $line
            }else{
                $appendLine = $properties[$currentKey] + " $line"
                $properties[$currentKey] = $appendLine
            }
        }  
        
    }
    Write-Output $properties
}