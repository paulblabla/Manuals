# Test Environment Setup Script
# Roept het hoofdscript aan met parameters voor test environment

# Vaste parameters voor test
$subscriptionId = "9c0da8ca-def9-45bd-a681-e4c91acdd81b"
$environmentName = "test"
$appName = "manuals-github-$environmentName"

# Voer het hoofdscript uit met de juiste parameters
$scriptPath = Join-Path $PSScriptRoot "setup-github-environment.ps1"
& $scriptPath -SubscriptionId $subscriptionId -EnvironmentName $environmentName -AppName $appName
