
# Please configure the following parameters

# WebCTRL username
$user = ''
# WebCTRL password
$pass = ''
# WebCTRL URL - be sure to include a trailing slash /
$url = ''
# Full URL to the trend graph you want to convert to PDF
$target = ''
# Sender email address
$email = ''
# Sender email password
$emailPassword = ''
# Semi-colon delimited list of recipient email addresses
$recipients = ''
# Email subject
$subject = 'WebCTRL Trend Graph'
# Email body
$body = 'Please see the attached PDF for the latest trend graph.'
# SMTP server for sender email
$smtpServer = 'smtp-mail.outlook.com'
# SMTP server port
$port = 587



$pass = cscript //nologo //E:jscript "$(Join-Path -Path $PSScriptRoot -ChildPath 'obfuscate.js')" "$pass"
$user = [uri]::EscapeDataString($user)
$pass = [uri]::EscapeDataString($pass)
$target = [uri]::EscapeDataString($target)
$cookieFile = Join-Path -Path $PSScriptRoot -ChildPath 'cookies.txt'

# Ensure curl.exe is in the PATH
$curlPath = "C:\curl\curl.exe"
if (Test-Path $curlPath) {
    & $curlPath --insecure -f -s -L -o nul -c "$cookieFile" -X POST -H 'Content-Type: application/x-www-form-urlencoded' -d "name=$user&pass=$pass" "$url"
} else {
    Write-Host "curl.exe not found. Please install curl and add it to the PATH."
}

$cookies = Get-Content -LiteralPath "$cookieFile" -Force -Raw -Encoding 'utf8'
$tail = ''
if ($cookies -match 'CJSTRICTREST\s+(\w+)'){
  $tail+="&a=$([uri]::EscapeDataString($Matches[1]))"
}
if ($cookies -match 'JSESSIONID\s+(\w+)'){
  $tail+="&b=$([uri]::EscapeDataString($Matches[1]))"
}
if ($cookies -match 'JSESSIONIDSSO\s+(\w+)'){
  $tail+="&c=$([uri]::EscapeDataString($Matches[1]))"
}

$pdfFile = Join-Path -Path $PSScriptRoot -ChildPath 'trend.pdf'
$chromePath = "$($Env:ProgramFiles)\Google\Chrome\Application\chrome.exe"

# Run Chrome with options to disable GPU and use no-sandbox
if (Test-Path $chromePath) {
    & $chromePath --headless --disable-gpu --disable-software-rasterizer --no-sandbox --disable-extensions --run-all-compositor-stages-before-draw --no-pdf-header-footer --virtual-time-budget=30000 --timeout=24000 --print-to-pdf="$pdfFile" --no-margins "$($url)CookieLoginUtility/168315DFF0DFA0518601C0D472FF4A4880BB70E0683D148B4C39B96959CC0770?redirect=$target&x=13766D7182B3CB40F27A4EB3D3D03481677ADFB15FB7A663C4C729E82DC80A47$tail"
} else {
    Write-Host "chrome.exe not found. Please install Google Chrome."
}

Start-Sleep -Seconds 30
Get-CimInstance Win32_Process -Filter "Name = 'chrome.exe' AND CommandLine LIKE '%--headless%'" | ForEach-Object { Stop-Process $_.ProcessId -ErrorAction SilentlyContinue }

if (Test-Path $curlPath) {
    & $curlPath --insecure -f -s -L -o nul -b "$cookieFile" "$($url)_common/servlet/lvl5/logout"
} else {
    Write-Host "curl.exe not found. Please install curl and add it to the PATH."
}

Remove-Item -LiteralPath "$cookieFile" -Force

if (Test-Path -LiteralPath "$pdfFile" -PathType 'Leaf'){
    Send-MailMessage -From "$email" -To $recipients.Split(';') -Subject "$subject" -Body "$body" -SmtpServer "$smtpServer" -Port 25 -Attachments "$pdfFile"
    Remove-Item -LiteralPath "$pdfFile" -Force
}
