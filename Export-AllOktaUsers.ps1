# Use TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Setup Auth Header
$header = @{
    Authorization = "SSWS <your api token>"
}

# API Resource Endpoint
$url = "https://<you okta domain>.okta.com/api/v1/users"

$Users = @()

do {
    $result = Invoke-WebRequest -Uri $url -Headers $header -UseBasicParsing
    $json = $result.Content | convertfrom-json
    $Users += $json
    $next = (($result.Headers.Link -split "`n")[1] -replace "[\<\>]" -split ";")[0]
    $url = $next

}
while ($result.Headers.Link[1] -match "next")

$Users | Foreach-object {
    
    [pscustomobject]@{
    FirstName = $_.profile.firstName
    LastName = $_.profile.lastName
    DisplayName = if ($_){$_.profile.displayName}else{$_}
    login = $_.profile.login
    email = $_.profile.email
    Desription = $_.profile.Description
    Department = $_.profile.department
    State = $_.status
    StatusChanged = $_.statusChanged
    Created = $_.created
    LastLogin = $_.lastLogin
    PasswordChanged = $_.passwordChanged
    Error = if ($_ -eq $null){"Something wrong"}else{}
    }
} | Export-Csv ./AllUsers-Feb2019.csv -Force

#Write-Output "($Users).count:OK"
