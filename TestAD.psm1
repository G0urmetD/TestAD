#Dot source all functions in all ps1 files located in the module's public and private folders, excluding tests and profiles.
Get-ChildItem -Path $PSScriptRoot\scripts\*.ps1 -ErrorAction SilentlyContinue |
ForEach-Object {
    . $_.FullName
}
