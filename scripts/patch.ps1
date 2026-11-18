$ErrorActionPreference = 'Stop'
$utf8 = New-Object System.Text.UTF8Encoding($false, $true)
function Get-TextHash([string]$value) {
  $sha = [Security.Cryptography.SHA256]::Create()
  try { return ([BitConverter]::ToString($sha.ComputeHash($utf8.GetBytes($value)))).Replace('-', '').ToLowerInvariant() }
  finally { $sha.Dispose() }
}
function Normalize([string]$value) { return $value.Replace("`r`n", "`n").Replace("`r", "`n") }
try {
  $config = $utf8.GetString([Convert]::FromBase64String('__PATCH_CONFIG__')) | ConvertFrom-Json
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
