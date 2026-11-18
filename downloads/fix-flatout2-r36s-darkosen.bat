@echo off
setlocal
title FlatOut 2 - R36S dArkOSen fix
set "FO2_FIX_SELF=%~f0"
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$text=[IO.File]::ReadAllText($env:FO2_FIX_SELF);$marker='#'+' POWERSHELL_PAYLOAD'; & ([scriptblock]::Create($text.Substring($text.IndexOf($marker)+$marker.Length)))"
set "FO2_FIX_RESULT=%errorlevel%"
echo.
if not "%~1"=="--no-pause" pause
exit /b %FO2_FIX_RESULT%
# POWERSHELL_PAYLOAD
$ErrorActionPreference = 'Stop'
$utf8 = New-Object System.Text.UTF8Encoding($false, $true)
function Get-TextHash([string]$value) {
  $sha = [Security.Cryptography.SHA256]::Create()
  try { return ([BitConverter]::ToString($sha.ComputeHash($utf8.GetBytes($value)))).Replace('-', '').ToLowerInvariant() }
  finally { $sha.Dispose() }
}
function Normalize([string]$value) { return $value.Replace("`r`n", "`n").Replace("`r", "`n") }
try {
  $config = $utf8.GetString([Convert]::FromBase64String('eyJuYW1lcyI6IFsiRmxhdE91dCAyIFtSSzMzMjYgLSAzMCBGUFNdLnNoIiwgIkZsYXRPdXQgMiBbSDcwMCAtIEZQUyBVbmxvY2tdLnNoIl0sICJiZWZvcmUiOiAiYTg0MjQzMjY1N2NiM2M5MDUzZDA0MmIzNTcwY2JiOGY4YmExMGZiMTFiNGQ0OWRiNzgwODU3N2RkNjg1OGZhNiIsICJhZnRlciI6ICI0NGUxMzAxNzBkYzBmMzQwMzlhMzJhYmMxZjE3NTI1MmEwYjMzMWVkYzBjM2Q1ZTkyNTkyNTg2ZTA1YTBiMjcwIiwgImNoYW5nZXMiOiBbeyJvbGQiOiAiZmlcblxuU0NSSVBUX0RJUj0iLCAibmV3IjogImZpXG5FU1VETz1cIiR7RVNVRE86LXN1ZG99XCJcbkNVUl9UVFk9XCIvZGV2L3R0eTFcIlxuXG5TQ1JJUFRfRElSPSJ9LCB7Im9sZCI6ICIgIGRvbmUgPCBmbzIuZW52XG5maVxuXG4jIFNhdmVnYW1lL2RldmljZS5jZmciLCAibmV3IjogIiAgZG9uZSA8IGZvMi5lbnZcbmZpXG5cbiMgUjM2UyAvIGRBcmtPU2VuIGRpYWdub3N0aWMgcHJvZmlsZS4gZm8yLmVudiBjYW4gb3ZlcnJpZGUgdGhlc2UgdmFsdWVzLlxuZXhwb3J0IFNETF9WSURFT0RSSVZFUj1cIiR7Rk8yX1RFU1RfVklERU9fRFJJVkVSOi1rbXNkcm19XCJcbmV4cG9ydCBTRExfQVVESU9EUklWRVI9XCIke0ZPMl9URVNUX0FVRElPX0RSSVZFUjotYWxzYX1cIlxuZXhwb3J0IEFMU09GVF9EUklWRVJTPWFsc2FcbmV4cG9ydCBTRExfVklERU9fR0xfRFJJVkVSPWxpYkdMRVN2Mi5zb1xuZXhwb3J0IFNETF9WSURFT19FR0xfRFJJVkVSPWxpYkVHTC5zb1xuZXhwb3J0IEZPMl9SRU5ERVI9XCIke0ZPMl9URVNUX1JFTkRFUjotNjQweDQ4MH1cIlxuZXhwb3J0IEZPMl9WSURFT19USFJFQURTPVwiJHtGTzJfVklERU9fVEhSRUFEUzotM31cIlxuZXhwb3J0IEZPMl9WSURFT19GQVNUPVwiJHtGTzJfVklERU9fRkFTVDotMX1cIlxuIyBLZWVwIHRoZSBjb25maWd1cmVkIENQVSBtYXhpbXVtIGZvciB0aGlzIGZpcnN0IGRpYWdub3N0aWMgcnVuLlxuZXhwb3J0IEZPMl9DUFVfQk9PU1Q9XCIke0ZPMl9DUFVfQk9PU1Q6LTB9XCJcbmVjaG8gXCJbbGF1bmNoZXJdIFIzNlMgZEFya09TZW4gdGVzdCBwcm9maWxlXCJcbmVjaG8gXCJbbGF1bmNoZXJdIHZpZGVvPSRTRExfVklERU9EUklWRVIgYXVkaW89JFNETF9BVURJT0RSSVZFUiByZW5kZXI9JEZPMl9SRU5ERVIgY2FwPSR7Rk8yX0NBUDotJERFRkFVTFRfQ0FQfVwiXG5lY2hvIFwiW2xhdW5jaGVyXSBDRlc9JHtDRldfTkFNRTotdW5rbm93bn0gdXNlcj0kKGlkKVwiXG5bIC1yIC9wcm9jL2RldmljZS10cmVlL21vZGVsIF0gJiYgeyB0ciAtZCAnXFwwMDAnIDwgL3Byb2MvZGV2aWNlLXRyZWUvbW9kZWw7IGVjaG87IH1cbmxzIC1sIC9kZXYvZHJpIC9kZXYvdHR5MSAyPi9kZXYvbnVsbFxuZnJlZSAtbVxuY29tbWFuZCAtdiBsZGQgPi9kZXYvbnVsbCAyPiYxICYmIGxkZCAuL2ZvMi5hYXJjaDY0XG5pZiBbIC1yIFwiJENVUl9UVFlcIiBdOyB0aGVuXG4gIGV4ZWMgPCBcIiRDVVJfVFRZXCJcbmVsc2VcbiAgZWNobyBcIltsYXVuY2hlcl0gQ2Fubm90IHJlYWQgJENVUl9UVFlcIlxuZmlcblxuIyBTYXZlZ2FtZS9kZXZpY2UuY2ZnIn0sIHsib2xkIjogImNsZWFudXAoKSB7XG4gIGtpbGwgXCIkV0FUQ0hfUElEXCIgMj4vZGV2L251bGxcbiAgZm9yIGVudHJ5IGluICRDTE9DS19TVEFURTsgZG8gd3N5cyBcIiR7ZW50cnklJT0qfVwiIFwiJHtlbnRyeSMqPX1cIjsgZG9uZVxuICBzeW5jXG59XG50cmFwIGNsZWFudXAgRVhJVFxuXG5jaG1vZCAreCAuL2ZvMi5hYXJjaDY0XG4jIEZPMl9DQVAgKGZvMi5lbnYpOiB0aGUgZnJhbWUgcmF0ZSBsaW1pdC4gNjAgbGV0cyBmcmFtZXMgYWx0ZXJuYXRlIGJldHdlZW4gb25lIGFuZCB0d28gcGFuZWwgcmVmcmVzaGVzIHdoZW4gdGhlIGdhbWVcbiMgY2Fubm90IGhvbGQgNjAsIGZlbHQgYXMgc3R1dHRlcjsgMzAgZ2l2ZXMgZXZlbiBmcmFtZXMuXG4uL2ZvMi5hYXJjaDY0IC0tY2FwPVwiJHtGTzJfQ0FQOi0kREVGQVVMVF9DQVB9XCJcbmVjaG8gXCJleGl0IGNvZGUgJD9cIiIsICJuZXciOiAiVlRfU1RBVEU9XCJcIlxuY2xlYW51cCgpIHtcbiAga2lsbCBcIiRXQVRDSF9QSURcIiAyPi9kZXYvbnVsbFxuICBmb3IgZW50cnkgaW4gJENMT0NLX1NUQVRFOyBkbyB3c3lzIFwiJHtlbnRyeSUlPSp9XCIgXCIke2VudHJ5Iyo9fVwiOyBkb25lXG4gIGZvciBlbnRyeSBpbiAkVlRfU1RBVEU7IGRvIHdzeXMgXCIke2VudHJ5JSU9Kn1cIiBcIiR7ZW50cnkjKj19XCI7IGRvbmVcbiAgaWYgWyAtdyBcIiRDVVJfVFRZXCIgXTsgdGhlbiBwcmludGYgJ1xcMDMzY1xcMDMzWz8yNWgnID4gXCIkQ1VSX1RUWVwiOyBmaVxuICBzeW5jXG59XG50cmFwIGNsZWFudXAgRVhJVFxudHJhcCAnZXhpdCAxMzAnIElOVFxudHJhcCAnZXhpdCAxNDMnIFRFUk1cblxuIyBHaXZlIFNETC9LTVNEUk0gYWNjZXNzIHRvIHRoZSBkaXNwbGF5LCByZXN0b3Jpbmcgb3JpZ2luYWwgYmluZGluZ3Mgb24gZXhpdC5cbmlmIFsgXCIkU0RMX1ZJREVPRFJJVkVSXCIgPSBcImttc2RybVwiIF07IHRoZW5cbiAgaWYgWyAtdyBcIiRDVVJfVFRZXCIgXTsgdGhlbiBwcmludGYgJ1xcMDMzY1xcMDMzWz8yNWwnID4gXCIkQ1VSX1RUWVwiOyBmaVxuICBmb3IgYmluZCBpbiAvc3lzL2NsYXNzL3Z0Y29uc29sZS92dGNvbiovYmluZDsgZG9cbiAgICBbIC1yIFwiJGJpbmRcIiBdIHx8IGNvbnRpbnVlXG4gICAgb2xkYmluZD0kKGNhdCBcIiRiaW5kXCIpXG4gICAgaWYgd3N5cyBcIiRiaW5kXCIgMDsgdGhlblxuICAgICAgVlRfU1RBVEU9XCIkVlRfU1RBVEUgJGJpbmQ9JG9sZGJpbmRcIlxuICAgIGVsc2VcbiAgICAgIGVjaG8gXCJbbGF1bmNoZXJdIENhbm5vdCByZWxlYXNlICRiaW5kXCJcbiAgICBmaVxuICBkb25lXG5maVxuc3luY1xuY2htb2QgK3ggLi9mbzIuYWFyY2g2NFxuIyBGTzJfQ0FQIChmbzIuZW52KTogdGhlIGZyYW1lIHJhdGUgbGltaXQuIDYwIGxldHMgZnJhbWVzIGFsdGVybmF0ZSBiZXR3ZWVuIG9uZSBhbmQgdHdvIHBhbmVsIHJlZnJlc2hlcyB3aGVuIHRoZSBnYW1lXG4jIGNhbm5vdCBob2xkIDYwLCBmZWx0IGFzIHN0dXR0ZXI7IDMwIGdpdmVzIGV2ZW4gZnJhbWVzLlxuZWNobyBcIltsYXVuY2hlcl0gU3RhcnRpbmcgZm8yLmFhcmNoNjRcIlxuIyBMaW5lIGJ1ZmZlcmluZyBrZWVwcyB0aGUgc3RhcnR1cCBkaWFnbm9zdGljcyB3aGVuIHRoZSBjb25zb2xlIGZyZWV6ZXMuXG5pZiBjb21tYW5kIC12IHN0ZGJ1ZiA+L2Rldi9udWxsIDI+JjE7IHRoZW5cbiAgc3RkYnVmIC1vTCAtZUwgLi9mbzIuYWFyY2g2NCAtLWNhcD1cIiR7Rk8yX0NBUDotJERFRkFVTFRfQ0FQfVwiXG5lbHNlXG4gIC4vZm8yLmFhcmNoNjQgLS1jYXA9XCIke0ZPMl9DQVA6LSRERUZBVUxUX0NBUH1cIlxuZmlcbkdBTUVfU1RBVFVTPSQ/XG5lY2hvIFwiW2xhdW5jaGVyXSBleGl0IGNvZGUgJEdBTUVfU1RBVFVTXCJcbmV4aXQgXCIkR0FNRV9TVEFUVVNcIiJ9XX0=')) | ConvertFrom-Json
  $root = Split-Path -Parent $env:FO2_FIX_SELF
  if (-not (Test-Path -LiteralPath (Join-Path $root 'flatout2/fo2.aarch64') -PathType Leaf)) {
    throw 'Place this BAT inside ports, beside the flatout2 folder. / Coloque o BAT em ports, ao lado da pasta flatout2.'
  }
  $plans = @()
  $found = 0
  foreach ($name in $config.names) {
    $path = Join-Path $root $name
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { continue }
    $found++
    $bytes = [IO.File]::ReadAllBytes($path)
    $text = Normalize ($utf8.GetString($bytes).TrimStart([char]0xFEFF))
    $hash = Get-TextHash $text
    if ($hash -eq $config.after) { Write-Host "Already fixed / Ja corrigido: $name"; continue }
    if ($hash -ne $config.before) { throw "Unsupported or modified launcher / Launcher diferente ou modificado: $name. Nothing changed / Nada alterado." }
    $patched = $text
    foreach ($change in $config.changes) {
      $count = [regex]::Matches($patched, [regex]::Escape([string]$change.old)).Count
      if ($count -ne 1) { throw 'Patch anchor mismatch. Nothing changed. / Trecho inesperado. Nada alterado.' }
      $patched = $patched.Replace([string]$change.old, [string]$change.new)
    }
    if ((Get-TextHash $patched) -ne $config.after) { throw 'Output verification failed. / Falha ao verificar resultado.' }
    $plans += [pscustomobject]@{ Path=$path; Name=$name; Bytes=$bytes; Text=$patched }
  }
  if ($found -eq 0) { throw 'No supported launchers found. New FlatOut 2.sh releases are not supported. / Nenhum launcher compativel encontrado. Releases com FlatOut 2.sh nao sao suportadas.' }
  if ($plans.Count -eq 0) { Write-Host 'No changes needed. / Nenhuma alteracao necessaria.'; exit 0 }
  $backup = Join-Path $root ('flatout2/backup-r36s-fix-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '-' + [guid]::NewGuid().ToString('N').Substring(0,8))
  [IO.Directory]::CreateDirectory($backup) | Out-Null
  foreach ($plan in $plans) { [IO.File]::WriteAllBytes((Join-Path $backup $plan.Name), $plan.Bytes) }
  $written = @()
  try {
    foreach ($plan in $plans) {
      # Recheck immediately before writing; retain originals for rollback.
      $current = [IO.File]::ReadAllBytes($plan.Path)
      if ([Convert]::ToBase64String($current) -ne [Convert]::ToBase64String($plan.Bytes)) { throw 'Launcher changed during preparation.' }
      $written += $plan
      [IO.File]::WriteAllText($plan.Path, $plan.Text, $utf8)
      if ((Get-TextHash ([IO.File]::ReadAllText($plan.Path, $utf8))) -ne $config.after) { throw 'Written file verification failed.' }
      Write-Host "Fixed / Corrigido: $($plan.Name)"
    }
  } catch {
    foreach ($plan in $written) { [IO.File]::WriteAllBytes($plan.Path, $plan.Bytes) }
    throw
  }
  Write-Host "Backup: $backup"
  Write-Host 'Done. Safely eject the card and test the 30 FPS launcher. / Concluido. Ejete o cartao e teste o launcher 30 FPS.'
  exit 0
} catch {
  Write-Host ('ERROR / ERRO: ' + $_.Exception.Message) -ForegroundColor Red
  exit 1
}
