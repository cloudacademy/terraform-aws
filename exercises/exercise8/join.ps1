<powershell>
<# Set Domain #>;
$ad_domain = "demo.cloudacademydevops.internal";

<# Set Credentials #>;
[string][ValidateNotNullOrEmpty()] $username = "demo.cloudacademydevops.internal\admin";
[string][ValidateNotNullOrEmpty()]$password = "0potC2Xk2X74%#!t"
$secpasswd = ConvertTo-SecureString -String $password -AsPlainText -Force
$creds = New-Object Management.Automation.PSCredential ($username, $secpasswd)

<# Join AD Domain #>;
Add-Computer -DomainName $ad_domain -Credential $creds -Passthru -Verbose -Force -Restart;
</powershell>