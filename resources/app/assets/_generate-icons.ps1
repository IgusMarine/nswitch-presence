Add-Type -AssemblyName System.Drawing
$assetsDir = $PSScriptRoot

function New-AppIcon {
    param([int]$size, [string]$outPath, [bool]$tray = $false)

    $bmp = New-Object System.Drawing.Bitmap($size, $size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.Clear([System.Drawing.Color]::Transparent)

    $cornerRadius = [int]($size * 0.22)
    $rect = New-Object System.Drawing.Rectangle(0, 0, $size, $size)
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddArc($rect.X, $rect.Y, $cornerRadius * 2, $cornerRadius * 2, 180, 90)
    $path.AddArc($rect.Right - $cornerRadius * 2, $rect.Y, $cornerRadius * 2, $cornerRadius * 2, 270, 90)
    $path.AddArc($rect.Right - $cornerRadius * 2, $rect.Bottom - $cornerRadius * 2, $cornerRadius * 2, $cornerRadius * 2, 0, 90)
    $path.AddArc($rect.X, $rect.Bottom - $cornerRadius * 2, $cornerRadius * 2, $cornerRadius * 2, 90, 90)
    $path.CloseFigure()

    if ($tray) {
        $brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(230, 0, 18))
    } else {
        $brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
            (New-Object System.Drawing.Point(0, 0)),
            (New-Object System.Drawing.Point($size, $size)),
            [System.Drawing.Color]::FromArgb(230, 0, 18),
            [System.Drawing.Color]::FromArgb(150, 0, 12)
        )
    }
    $g.FillPath($brush, $path)

    # Joy-Cons (two rounded rectangles in white)
    $jcMargin = [int]($size * 0.20)
    $jcGap = [int]($size * 0.07)
    $jcWidth = [int](($size - $jcMargin * 2 - $jcGap) / 2)
    $jcHeight = [int]($size - $jcMargin * 2)
    $jcRadius = [Math]::Max(2, [int]($jcWidth * 0.20))

    $whiteBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)

    foreach ($i in 0,1) {
        $jcX = $jcMargin + ($jcWidth + $jcGap) * $i
        $jcY = $jcMargin
        $jcPath = New-Object System.Drawing.Drawing2D.GraphicsPath
        $jcPath.AddArc($jcX, $jcY, $jcRadius * 2, $jcRadius * 2, 180, 90)
        $jcPath.AddArc($jcX + $jcWidth - $jcRadius * 2, $jcY, $jcRadius * 2, $jcRadius * 2, 270, 90)
        $jcPath.AddArc($jcX + $jcWidth - $jcRadius * 2, $jcY + $jcHeight - $jcRadius * 2, $jcRadius * 2, $jcRadius * 2, 0, 90)
        $jcPath.AddArc($jcX, $jcY + $jcHeight - $jcRadius * 2, $jcRadius * 2, $jcRadius * 2, 90, 90)
        $jcPath.CloseFigure()
        $g.FillPath($whiteBrush, $jcPath)

        if ($size -ge 32) {
            $dotSize = [Math]::Max(2, [int]($size * 0.06))
            $dotX = $jcX + ($jcWidth - $dotSize) / 2
            $dotY = if ($i -eq 0) { $jcY + $jcHeight * 0.18 } else { $jcY + $jcHeight * 0.76 }
            $redBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(230, 0, 18))
            $g.FillEllipse($redBrush, $dotX, $dotY, $dotSize, $dotSize)
            $redBrush.Dispose()
        }
    }

    $g.Dispose()
    $bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    $brush.Dispose()
    $whiteBrush.Dispose()
    Write-Output "Generated $outPath ($size x $size)"
}

$sizes = @(16, 32, 48, 64, 128, 256)
$pngPaths = @()
foreach ($s in $sizes) {
    $p = Join-Path $assetsDir "icon-$s.png"
    New-AppIcon -size $s -outPath $p
    $pngPaths += $p
}

# Tray icons (smaller, solid)
New-AppIcon -size 16 -outPath (Join-Path $assetsDir "tray-icon.png") -tray $true
New-AppIcon -size 32 -outPath (Join-Path $assetsDir "tray-icon@2x.png") -tray $true

# Main window icon (single PNG)
Copy-Item -Path (Join-Path $assetsDir "icon-256.png") -Destination (Join-Path $assetsDir "icon.png") -Force

# Build ICO with embedded PNGs
function New-IcoFromPngs {
    param([string[]]$pngPaths, [string]$outPath)
    $images = @()
    foreach ($p in $pngPaths) {
        $bytes = [System.IO.File]::ReadAllBytes($p)
        $bmp = [System.Drawing.Image]::FromFile($p)
        $w = $bmp.Width
        $h = $bmp.Height
        $bmp.Dispose()
        $images += @{ Bytes = $bytes; Width = $w; Height = $h }
    }
    $stream = New-Object System.IO.MemoryStream
    $writer = New-Object System.IO.BinaryWriter($stream)
    $writer.Write([uint16]0)
    $writer.Write([uint16]1)
    $writer.Write([uint16]$images.Count)
    $offset = 6 + ($images.Count * 16)
    foreach ($img in $images) {
        $w = if ($img.Width -ge 256) { 0 } else { $img.Width }
        $h = if ($img.Height -ge 256) { 0 } else { $img.Height }
        $writer.Write([byte]$w)
        $writer.Write([byte]$h)
        $writer.Write([byte]0)
        $writer.Write([byte]0)
        $writer.Write([uint16]1)
        $writer.Write([uint16]32)
        $writer.Write([uint32]$img.Bytes.Length)
        $writer.Write([uint32]$offset)
        $offset += $img.Bytes.Length
    }
    foreach ($img in $images) { $writer.Write($img.Bytes) }
    [System.IO.File]::WriteAllBytes($outPath, $stream.ToArray())
    $writer.Dispose()
    $stream.Dispose()
    Write-Output "Generated $outPath"
}

New-IcoFromPngs -pngPaths $pngPaths -outPath (Join-Path $assetsDir "icon.ico")
Write-Output "DONE"
