# PowerShell helper to deploy Cloud Functions for this project

Write-Host "This script will set SendGrid config (if provided), install function deps and deploy functions."

param(
  [string]$SendGridKey = '',
  [switch]$SkipInstall
)

if ($SendGridKey -ne '') {
  Write-Host "Setting SendGrid key in functions config..."
  firebase functions:config:set sendgrid.key="$SendGridKey"
}

if (-not $SkipInstall) {
  Write-Host "Installing NPM dependencies in functions/..."
  Push-Location .\functions
  npm install
  Pop-Location
}

Write-Host "Deploying functions..."
firebase deploy --only functions

Write-Host "Done. After deploy, note the HTTPS URL for resetPasswordWithOtp and paste it into the app via AuthService.setFunctionsBaseUrl('<URL>') in lib/main.dart or provide it to the developer."}