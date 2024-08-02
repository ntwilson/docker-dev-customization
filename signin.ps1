Invoke-Expression ('$env:' + $((op signin | select -first 1) -replace "export ",""))

