[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# nmap
Invoke-WebRequest -Uri "https://nmap.org/dist/nmap-7.92-setup.exe" -OutFile "nmap.exe"

# splunk forwarder
Invoke-WebRequest -Uri "https://download.splunk.com/products/universalforwarder/releases/8.2.3/windows/splunkforwarder-8.2.3-cd0848707637-x64-release.msi" -OutFile "splunkforwarder.msi"
msiexec.exe /i splunkforwarder.msi RECEIVING_INDEXER="<IP>:<PORT>" WINEVENTLOG_SEC_ENABLE=1 WINEVENTLOG_SYS_ENABLE=1 AGREETOLICENSE=Yes /quiet

# MalwareBytes
Invoke-WebRequest -Uri "https://downloads.malwarebytes.com/file/mb-windows"-OutFile "MalwareBytes.exe"

# PatchMyPC
Invoke-WebRequest -Uri "https://patchmypc.com/freeupdater/PatchMyPC.exe"-OutFile "PatchMyPC.exe"
