<powershell>
<# Install Dependencies #>;
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force;
Install-Module -Name AWS.Tools.Installer -Scope AllUsers -Force;
<# Define Variables #>;
$ad_secret_id = "${ad_secret_id}";
$ad_domain = "${ad_domain}";
<# Read secret from the Secret Manager #>;
$secret_manager = Get-SECSecretValue -SecretId $ad_secret_id;
<# Convert the Secret JSON into an object #>;
$ad_secret = $secret_manager.SecretString | ConvertFrom-Json;
<# Set Credentials #>;
$username = $ad_secret.Username + "@" + $ad_domain;
$password = $ad_secret.Password | ConvertTo-SecureString -AsPlainText -Force;
$credential = New-Object System.Management.Automation.PSCredential($username, $password);
<# Join AD Domain #>;
Add-Computer -DomainName $ad_domain -Credential $credential -Passthru -Verbose -Force -Restart;
</powershell>
