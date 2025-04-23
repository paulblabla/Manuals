# Production Environment Setup Script
# Roept het hoofdscript aan met parameters voor production environment

# Vaste parameters voor production
$subscriptionId = "9c0da8ca-def9-45bd-a681-e4c91acdd81b"
$environmentName = "production"
$appName = "manuals-github-$environmentName"

# Voer het hoofdscript uit met de juiste parameters
$scriptPath = Join-Path $PSScriptRoot "setup-github-environment.ps1"
& $scriptPath -SubscriptionId $subscriptionId -EnvironmentName $environmentName -AppName $appName
