function sudo {
    param (
        [Parameter(Mandatory=$true, ValueFromRemainingArguments=$true)]
        [String[]]$Command
    )
    if ($Command.Length -eq 1) {
        Start-Process -FilePath $Command[0] -Verb RunAs -Wait
    } else {
        $argsList = $Command[1..($Command.Length - 1)] -join ' '
        Start-Process -FilePath $Command[0] -ArgumentList $argsList -Verb RunAs -Wait
    }
}

function google {
    $query = $args -join " "
    if ($query) {
        Start-Process "https://www.google.com/search?q=$([uri]::EscapeDataString($query))"
    }
}
