FROM mcr.microsoft.com/powershell
RUN ["pwsh", "-Command", "$ver = (Invoke-WebRequest -UseBasicParsing https://storage.googleapis.com/kubernetes-release/release/stable.txt).Content ; \
    Invoke-WebRequest -UseBasicParsing -OutFile ./kubectl -Uri \
    \"https://storage.googleapis.com/kubernetes-release/release/$($ver.TrimEnd())/bin/linux/amd64/kubectl\"" ]
RUN chmod +x kubectl

ADD update_azurecni.ps1 .
ENTRYPOINT [ "pwsh", "-File", "update_azurecni.ps1" ]