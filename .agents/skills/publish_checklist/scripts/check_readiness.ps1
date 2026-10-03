# ==============================================================================
# Android & Flutter Publishing Readiness Checker
# Path: .agents/skills/publish_checklist/scripts/check_readiness.ps1
# ==============================================================================

$passedCount = 0
$warnCount = 0
$failCount = 0

function Write-CheckHeader {
    param([string]$title)
    Write-Host "`n=======================================================" -ForegroundColor Cyan
    Write-Host "  $title" -ForegroundColor Cyan
    Write-Host "=======================================================" -ForegroundColor Cyan
}

function Report-Pass {
    param([string]$message)
    $global:passedCount++
    Write-Host "  [OK] " -ForegroundColor Green -NoNewline
    Write-Host $message
}

function Report-Warn {
    param([string]$message)
    $global:warnCount++
    Write-Host "  [WARN] " -ForegroundColor Yellow -NoNewline
    Write-Host $message
}

function Report-Fail {
    param([string]$message, [string]$recommendation)
    $global:failCount++
    Write-Host "  [ACTION REQUIRED] " -ForegroundColor Red -NoNewline
    Write-Host $message
    if ($recommendation) {
        Write-Host "      -> $recommendation" -ForegroundColor DarkGray
    }
}

Write-Host "`n+------------------------------------------------------+" -ForegroundColor Magenta
Write-Host "|   Android & Flutter Play Store Pre-Flight Audit      |" -ForegroundColor Magenta
Write-Host "+------------------------------------------------------+" -ForegroundColor Magenta

# Check working directory
$projectRoot = Get-Location
$isFlutter = Test-Path "pubspec.yaml"
$hasAndroidDir = Test-Path "android"

if (-not $hasAndroidDir) {
    Write-Host "Error: No 'android' directory found in $projectRoot. Please run from the root of a Flutter/Android project." -ForegroundColor Red
    exit 1
}

# ------------------------------------------------------------------------------
# 1. APP IDENTITY & VERSIONING
# ------------------------------------------------------------------------------
Write-CheckHeader "1. App Identity & Versioning"

# Check pubspec.yaml
if ($isFlutter) {
    $pubspec = Get-Content "pubspec.yaml" -Raw
    if ($pubspec -match "version:\s*([0-9\.\+]+)") {
        $version = $matches[1]
        Report-Pass "Flutter Version defined: $version"
    } else {
        Report-Fail "No 'version' field found in pubspec.yaml" "Add 'version: 1.0.0+1' in pubspec.yaml"
    }
}

# Check AndroidManifest.xml
$manifestPath = "android/app/src/main/AndroidManifest.xml"
if (Test-Path $manifestPath) {
    $manifestContent = Get-Content $manifestPath -Raw
    
    # App Label check
    if ($manifestContent -match 'android:label="([^"]+)"') {
        $appLabel = $matches[1]
        if ($appLabel -match "^[a-z0-9_]+$") {
            Report-Warn "android:label is '$appLabel' (raw/snake_case). Consider using a human-readable title like 'Gym Interval Timer'."
        } else {
            Report-Pass "User-facing app label: '$appLabel'"
        }
    } else {
        Report-Warn "No android:label explicitly found in AndroidManifest.xml"
    }
} else {
    Report-Fail "AndroidManifest.xml not found at $manifestPath" "Ensure Android project structure is intact"
}

# Check Application ID in build.gradle / build.gradle.kts
$gradleKts = "android/app/build.gradle.kts"
$gradleGroovy = "android/app/build.gradle"
$targetGradle = if (Test-Path $gradleKts) { $gradleKts } elseif (Test-Path $gradleGroovy) { $gradleGroovy } else { $null }

if ($targetGradle) {
    $gradleContent = Get-Content $targetGradle -Raw
    if ($gradleContent -match 'applicationId\s*=\s*"([^"]+)"' -or $gradleContent -match "applicationId\s+'([^']+)'") {
        $appId = $matches[1]
        if ($appId -match "^com\.example\.") {
            Report-Fail "Application ID uses default 'com.example' namespace ($appId)" "Change applicationId in $targetGradle to a unique package name"
        } else {
            Report-Pass "Application ID configured: $appId"
        }
    }

    # Target SDK check
    if ($gradleContent -match 'targetSdk\s*=\s*([0-9]+)' -or $gradleContent -match 'targetSdkVersion\s+([0-9]+)') {
        $targetSdk = [int]$matches[1]
        if ($targetSdk -ge 34) {
            Report-Pass "targetSdk is $targetSdk (meets Google Play requirement: >= 34)"
        } else {
            Report-Fail "targetSdk is $targetSdk. Google Play requires targetSdk >= 34 for new apps/updates" "Update targetSdk to 34 or 35 in $targetGradle"
        }
    }
}

# ------------------------------------------------------------------------------
# 2. KEYSTORE & SIGNING CONFIGURATION
# ------------------------------------------------------------------------------
Write-CheckHeader "2. Keystore & Release Signing"

$keyPropertiesPath = "android/key.properties"
$hasKeyProperties = Test-Path $keyPropertiesPath

if ($hasKeyProperties) {
    Report-Pass "android/key.properties exists"
    $keyPropsContent = Get-Content $keyPropertiesPath -Raw
    if ($keyPropsContent -match 'storeFile\s*=\s*(.+)') {
        $keystoreFile = $matches[1].Trim()
        $foundKey = (Test-Path $keystoreFile) -or (Test-Path "android/$keystoreFile") -or (Test-Path "android/app/$keystoreFile")
        if ($foundKey) {
            Report-Pass "Keystore file exists on disk: $keystoreFile"
        } else {
            Report-Warn "Keystore file path specified in key.properties does not exist on disk: $keystoreFile"
        }
    }
} else {
    Report-Fail "android/key.properties is missing" "Create upload-keystore.jks with keytool, then configure android/key.properties"
}

# Check Gradle Release Signing config
if ($targetGradle) {
    $gradleContent = Get-Content $targetGradle -Raw
    $hasReleaseConfigured = $gradleContent -match 'signingConfig\s*=\s*signingConfigs\.getByName\("release"\)' -or $gradleContent -match 'signingConfig\s+signingConfigs\.release'
    $hasDebugInRelease = $gradleContent -match 'signingConfig\s*=\s*signingConfigs\.getByName\("debug"\)' -or $gradleContent -match 'signingConfig\s+signingConfigs\.debug'

    if ($hasReleaseConfigured) {
        Report-Pass "build.gradle is configured to sign release builds with 'release' signingConfig"
    } elseif ($hasDebugInRelease) {
        Report-Fail "build.gradle release buildType is still signing with 'debug' keys!" "Update $targetGradle to use signingConfigs.getByName('release')"
    } else {
        Report-Warn "No explicit release signing configuration detected in $targetGradle"
    }
}

# Check .gitignore security
if (Test-Path ".gitignore") {
    $gitignoreContent = Get-Content ".gitignore" -Raw
    $ignoresJks = $gitignoreContent -match "\*\.jks" -or $gitignoreContent -match "\*\.keystore"
    $ignoresProps = $gitignoreContent -match "key\.properties"

    if ($ignoresJks -and $ignoresProps) {
        Report-Pass ".gitignore protects keystores (*.jks) and key.properties from git commits"
    } else {
        Report-Fail ".gitignore does not protect signing keys!" "Add *.jks, *.keystore, and key.properties to .gitignore"
    }
}

# ------------------------------------------------------------------------------
# 3. ADMOB & THIRD-PARTY SERVICES
# ------------------------------------------------------------------------------
Write-CheckHeader "3. Monetization & AdMob Credentials"

$testAppId = "ca-app-pub-3940256099942544~3347511713"

if (Test-Path $manifestPath) {
    $manifestContent = Get-Content $manifestPath -Raw
    if ($manifestContent -match $testAppId) {
        Report-Fail "Google AdMob Test App ID found in AndroidManifest.xml" "Replace '$testAppId' with your real production AdMob App ID from Google AdMob console"
    } elseif ($manifestContent -match 'com\.google\.android\.gms\.ads\.APPLICATION_ID') {
        Report-Pass "AdMob APPLICATION_ID found and does not match standard test ID"
    }
}

# Check Dart files for test ad flags / unit IDs
if (Test-Path "lib") {
    $dartFilesWithTestAds = Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse | Where-Object {
        $content = Get-Content $_.FullName -Raw
        $content -match 'useTestAds\s*=\s*true' -or $content -match "ca-app-pub-3940256099942544" -or $content -match "ca-app-pub-X{5,}"
    }

    if ($dartFilesWithTestAds) {
        foreach ($file in $dartFilesWithTestAds) {
            $relPath = Resolve-Path -Path $file.FullName -Relative
            Report-Fail "Test AdMob configuration found in $relPath" "Set 'useTestAds = false' and replace placeholder unit IDs with real production Ad Unit IDs"
        }
    } else {
        Report-Pass "No hardcoded test AdMob flags detected in lib/"
    }
}

# ------------------------------------------------------------------------------
# 4. PERMISSIONS & MANIFEST INSPECTION
# ------------------------------------------------------------------------------
Write-CheckHeader "4. Permissions & Manifest Inspection"

if (Test-Path $manifestPath) {
    $manifestContent = Get-Content $manifestPath -Raw
    $permissions = [regex]::Matches($manifestContent, '<uses-permission\s+android:name="([^"]+)"') | ForEach-Object { $_.Groups[1].Value }
    
    if ($permissions.Count -gt 0) {
        Write-Host "  Declared Permissions:" -ForegroundColor DarkCyan
        foreach ($perm in $permissions) {
            Write-Host "    - $perm" -ForegroundColor Gray
            if ($perm -match "ACCESS_FINE_LOCATION|ACCESS_COARSE_LOCATION|CAMERA|RECORD_AUDIO|READ_EXTERNAL_STORAGE|WRITE_EXTERNAL_STORAGE|READ_MEDIA|SCHEDULE_EXACT_ALARM|USE_FULL_SCREEN_INTENT") {
                Report-Warn "Sensitive permission declared: $perm (Requires justification/disclosure in Play Console)"
            }
        }
    } else {
        Report-Pass "Minimal or no custom permissions declared"
    }
}

# ------------------------------------------------------------------------------
# 5. RELEASE ARTIFACTS
# ------------------------------------------------------------------------------
Write-CheckHeader "5. Release Artifacts (App Bundle / AAB)"

$aabPath = "build/app/outputs/bundle/release/app-release.aab"
if (Test-Path $aabPath) {
    $aabFile = Get-Item $aabPath
    $sizeMb = [math]::Round($aabFile.Length / 1MB, 2)
    Report-Pass "Production AAB found: $aabPath ($sizeMb MB, Last Modified: $($aabFile.LastWriteTime))"
} else {
    Report-Warn "No production AAB bundle found at $aabPath (Run 'flutter build appbundle --release')"
}

# ------------------------------------------------------------------------------
# AUDIT SUMMARY
# ------------------------------------------------------------------------------
Write-Host "`n+------------------------------------------------------+" -ForegroundColor Magenta
Write-Host "  AUDIT SUMMARY" -ForegroundColor Magenta
Write-Host "+------------------------------------------------------+" -ForegroundColor Magenta
Write-Host ("  Passed checks:        " + $passedCount) -ForegroundColor Green
Write-Host ("  Warnings to review:   " + $warnCount) -ForegroundColor Yellow
Write-Host ("  Actions required:     " + $failCount) -ForegroundColor Red
Write-Host "--------------------------------------------------------" -ForegroundColor DarkGray

if ($failCount -eq 0 -and $warnCount -eq 0) {
    Write-Host "`nSTATUS: All automated checks passed! Ready for Google Play Console upload." -ForegroundColor Green
} elseif ($failCount -eq 0) {
    Write-Host "`nSTATUS: No blocking errors, but please review the warnings above before release." -ForegroundColor Yellow
} else {
    Write-Host ("`nSTATUS BLOCKED: Please resolve the " + $failCount + " [ACTION REQUIRED] items above before publishing.") -ForegroundColor Red
}
Write-Host ""
