cd /root

curl -OJL (curl -s https://api.github.com/repos/PowerShell/PowerShellEditorServices/releases/latest | grep browser_download_url | cut -d '"' -f 4)
Expand-Archive PowerShellEditorServices.zip -DestinationPath .pwsh-es

rm PowerShellEditorServices.zip

