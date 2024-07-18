$ModulePath = ($env:PSModulePath).Split(':') | select -first 1

$contents = cat "$ModulePath/dotenv/0.1.0/dotenv.psd1"

$newContents = $contents -replace "# RootModule = ''","RootModule = 'dotenv.psm1'"

$newContents > "$ModulePath/dotenv/0.1.0/dotenv.psd1"
