Param(
  [Parameter(Mandatory=$true)][string]$win_user,
  [Parameter(Mandatory=$true)][string]$win_pass,
  [Parameter(Mandatory=$true)][string]$azurecni_version
)

$passwd = ConvertTo-SecureString $win_pass -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($win_user, $passwd) 

$azurecni_url = "https://github.com/Azure/azure-container-networking/releases/download/$($azurecni_version)/azure-vnet-cni-windows-amd64-$($azurecni_version).zip"

$nodes = ./kubectl get node -o json | ConvertFrom-Json
$nodes.items | Where-Object { $_.metadata.labels.'beta.kubernetes.io/os' -eq 'windows' } | foreach-object { 
  ./kubectl cordon $_.status.nodeInfo.machineID
  Add-Member -InputObject $_ -MemberType NoteProperty -Name "pssession" -Value (New-PSSession -ComputerName $_.status.nodeInfo.machineID -Credential $cred -UseSSL -Authentication basic) -Force; 
  Write-Host Connected to $_.status.nodeInfo.machineID; 
  Invoke-Command -Session $_.pssession { 
    Stop-service kubelet -force
    [Net.ServicePointManager]::SecurityProtocol = "tls12"
    Invoke-WebRequest -UseBasicParsing -Uri $using:azurecni_url -OutFile C:\bin.zip
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory("C:\bin.zip", "C:\bin")
    Move-Item C:\bin\azure-vnet.exe C:\k\azurecni\bin\ -Force
    Move-Item C:\bin\azure-vnet-ipam.exe C:\k\azurecni\bin\ -Force
    Move-Item C:\bin\10-azure.conflist C:\k\azurecni\netconf\ -Force
    Remove-Item C:\k\azure-vnet.json -Force -ErrorAction SilentlyContinue
    get-hnsnetwork | ? Name -Like "Azure" | remove-hnsnetwork
    Start-service kubelet 
  }
  ./kubectl uncordon $_.status.nodeInfo.machineID
}
