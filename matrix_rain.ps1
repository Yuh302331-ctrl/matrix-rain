param(
    [double]$Seconds = 0,
    [int]$Cols = 0,
    [int]$Rows = 0
)

# Green matrix rain for Windows PowerShell.
# Usage:
#   powershell -ExecutionPolicy Bypass -File matrix_rain.ps1
#   powershell -ExecutionPolicy Bypass -File matrix_rain.ps1 -Seconds 10
# Press Ctrl+C to stop.

$ErrorActionPreference = 'SilentlyContinue'

$signature = '[DllImport("kernel32.dll")] public static extern IntPtr GetStdHandle(int n);
[DllImport("kernel32.dll")] public static extern bool GetConsoleMode(IntPtr h, out uint m);
[DllImport("kernel32.dll")] public static extern bool SetConsoleMode(IntPtr h, uint m);'

$vt = Add-Type -MemberDefinition $signature -Name 'Vt' -Namespace 'Win32' -PassThru
if ($vt) {
    $handle = $vt::GetStdHandle(-11)
    $mode = 0
    [void]$vt::GetConsoleMode($handle, [ref]$mode)
    [void]$vt::SetConsoleMode($handle, $mode -bor 4)
}

try {
    $w = [Console]::WindowWidth
    $hh = [Console]::WindowHeight
}
catch {
    $w = 80
    $hh = 24
}
if ($Cols -gt 0) { $w = $Cols }
if ($Rows -gt 0) { $hh = $Rows }
$w = [Math]::Max(10, [Math]::Min(200, $w - 1))
$hh = [Math]::Max(8, $hh - 1)

$chars = ('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#$%&*+=<>~^').ToCharArray()
$rnd = New-Object System.Random
$grid = New-Object 'int[,]' $hh, $w
$heads = New-Object int[] $w
for ($i = 0; $i -lt $w; $i++) { $heads[$i] = -999 }

$ESC = [char]27
$sb = New-Object System.Text.StringBuilder
$delayMs = 35
$frame = 0

[Console]::Out.Write("$ESC[2J$ESC[H$ESC[?25l")

$sw = [System.Diagnostics.Stopwatch]::StartNew()
try {
    while ($true) {
        if ($Seconds -gt 0 -and $sw.Elapsed.TotalSeconds -ge $Seconds) { break }
        $ft = [System.Diagnostics.Stopwatch]::StartNew()

        for ($y = 0; $y -lt $hh; $y++) {
            for ($x = 0; $x -lt $w; $x++) {
                $v = $grid[$y, $x]
                if ($v -gt 0) { $grid[$y, $x] = $v - 1 }
            }
        }

        for ($x = 0; $x -lt $w; $x++) {
            $hd = $heads[$x]
            if ($hd -lt -1) {
                if ($rnd.NextDouble() -lt 0.04) { $heads[$x] = -1 }
            }
            elseif (($frame % 2) -eq 0) {
                $ny = $hd + 1
                if ($ny -ge $hh) { $heads[$x] = -999 }
                else { $grid[$ny, $x] = 4; $heads[$x] = $ny }
            }
        }

        [void]$sb.Clear()
        [void]$sb.Append("$ESC[H")
        for ($y = 0; $y -lt $hh; $y++) {
            for ($x = 0; $x -lt $w; $x++) {
                $v = $grid[$y, $x]
                if ($v -gt 0) {
                    $c = $chars[$rnd.Next($chars.Length)]
                    if ($v -ge 4) { [void]$sb.Append("$ESC[92;1m$c$ESC[0m") }
                    elseif ($v -eq 3) { [void]$sb.Append("$ESC[92m$c$ESC[0m") }
                    elseif ($v -eq 2) { [void]$sb.Append("$ESC[32m$c$ESC[0m") }
                    else { [void]$sb.Append("$ESC[2;32m$c$ESC[0m") }
                }
                else { [void]$sb.Append(' ') }
            }
            if ($y -lt $hh - 1) { [void]$sb.Append("`r`n") }
        }
        [Console]::Out.Write($sb.ToString())
        $frame++

        $ms = $ft.ElapsedMilliseconds
        if ($ms -lt $delayMs) { Start-Sleep -Milliseconds ($delayMs - $ms) }
    }
}
finally {
    [Console]::Out.Write("$ESC[0m$ESC[?25h$ESC[H$ESC[2J")
    [Console]::Out.Flush()
}