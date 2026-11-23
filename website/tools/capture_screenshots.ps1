# Poswal Orbit · Automated Headless Screenshot Capture
param (
    [string]$OutputDir = "D:\Desktop\reference\website-checks"
)

if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

$tempProfile = "C:\Users\tofee\AppData\Local\Temp\edge_screenshot_profile"
if (Test-Path $tempProfile) {
    Remove-Item $tempProfile -Recurse -Force -ErrorAction SilentlyContinue
}

$edgePath = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"

$cases = @(
    @{ name = "01-desktop-1280px-dark-en.png"; width = 1280; height = 900; url = "file:///D:/Desktop/Poswal/website/dist/index.html" },
    @{ name = "02-desktop-1920px-dark-en.png"; width = 1920; height = 1080; url = "file:///D:/Desktop/Poswal/website/dist/index.html" },
    @{ name = "03-tablet-768px-dark-en.png"; width = 768; height = 1024; url = "file:///D:/Desktop/Poswal/website/dist/index.html" },
    @{ name = "04-mobile-390px-dark-en.png"; width = 390; height = 844; url = "file:///D:/Desktop/Poswal/website/dist/index.html" },
    @{ name = "05-mobile-360px-dark-en.png"; width = 360; height = 780; url = "file:///D:/Desktop/Poswal/website/dist/index.html" },
    @{ name = "06-desktop-1280px-light-en.png"; width = 1280; height = 900; url = "file:///D:/Desktop/Poswal/website/dist/index.html?theme=light" },
    @{ name = "07-desktop-1280px-oled-en.png"; width = 1280; height = 900; url = "file:///D:/Desktop/Poswal/website/dist/index.html?theme=oled" },
    @{ name = "08-desktop-1280px-dark-hi.png"; width = 1280; height = 900; url = "file:///D:/Desktop/Poswal/website/dist/hi/index.html" },
    @{ name = "09-desktop-1280px-dark-ur-rtl.png"; width = 1280; height = 900; url = "file:///D:/Desktop/Poswal/website/dist/ur/index.html" },
    @{ name = "10-mobile-390px-dark-ur-rtl.png"; width = 390; height = 844; url = "file:///D:/Desktop/Poswal/website/dist/ur/index.html" }
)

foreach ($c in $cases) {
    $outPath = Join-Path $OutputDir $c.name
    Write-Host "Capturing $($c.name)..."
    $edgeArgs = @(
        "--headless=new",
        "--user-data-dir=$tempProfile",
        "--window-size=$($c.width),$($c.height)",
        "--screenshot=$outPath",
        "--hide-scrollbars",
        $c.url
    )
    Start-Process -FilePath $edgePath -ArgumentList $edgeArgs -Wait
}

Write-Host "All screenshots captured in $OutputDir"
