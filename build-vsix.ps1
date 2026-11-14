# Build Pinkie for VS Code VSIX Package cleanly
Add-Type -AssemblyName System.IO.Compression.FileSystem

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$outputVsix = Join-Path $scriptDir "pinkie-for-vscode.vsix"
$outputZip = Join-Path $scriptDir "Pinkie-for-Vscode.zip"
$tempDir = Join-Path $env:TEMP ("pinkie_vsix_build_" + [Guid]::NewGuid().ToString("N"))

New-Item -ItemType Directory -Path "$tempDir\extension" -Force | Out-Null

# Copy extension files
Copy-Item (Join-Path $scriptDir "package.json") "$tempDir\extension\"
Copy-Item (Join-Path $scriptDir "icon.png") "$tempDir\extension\"
Copy-Item (Join-Path $scriptDir "dark-icon.png") "$tempDir\extension\"
Copy-Item (Join-Path $scriptDir "README.md") "$tempDir\extension\"
Copy-Item (Join-Path $scriptDir "CHANGELOG.md") "$tempDir\extension\"
Copy-Item (Join-Path $scriptDir "themes") "$tempDir\extension\themes" -Recurse

# Create [Content_Types].xml
$contentTypes = @'
<?xml version="1.0" encoding="utf-8"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="json" ContentType="application/json"/>
  <Default Extension="md" ContentType="text/markdown"/>
  <Default Extension="png" ContentType="image/png"/>
  <Default Extension="vsixmanifest" ContentType="text/xml"/>
  <Default Extension="txt" ContentType="text/plain"/>
</Types>
'@
[System.IO.File]::WriteAllText("$tempDir\[Content_Types].xml", $contentTypes, [System.Text.Encoding]::UTF8)

# Create extension.vsixmanifest
$vsixManifest = @'
<?xml version="1.0" encoding="utf-8"?>
<PackageManifest Version="2.0.0" xmlns="http://schemas.microsoft.com/developer/vsx-schema/2011" xmlns:d="http://schemas.microsoft.com/developer/vsx-schema/design/2011">
  <Metadata>
    <Identity Id="pinkie-for-vscode" Version="1.1.0" Language="en-US" Publisher="cmduyeen"/>
    <DisplayName>Pinkie for VS Code</DisplayName>
    <Description xml:space="preserve">An elegant, soothing pastel-pink and soft-white kawaii theme for Visual Studio Code ~ 🌸 ♡</Description>
    <Tags>theme,color-theme,pink,pastel,kawaii,cute,light</Tags>
    <Categories>Themes</Categories>
    <GalleryFlags>Public</GalleryFlags>
    <Icon>extension/icon.png</Icon>
    <Properties>
      <Property Id="Microsoft.VisualStudio.Code.Engine" Value="^1.60.0"/>
      <Property Id="Microsoft.VisualStudio.Code.ExtensionDependencies" Value=""/>
      <Property Id="Microsoft.VisualStudio.Code.ExtensionPack" Value=""/>
      <Property Id="Microsoft.VisualStudio.Code.LocalizedLanguages" Value=""/>
    </Properties>
    <License>extension/LICENSE</License>
  </Metadata>
  <Installation>
    <InstallationTarget Id="Microsoft.VisualStudio.Code"/>
  </Installation>
  <Dependencies/>
  <Assets>
    <Asset Type="Microsoft.VisualStudio.Code.Manifest" Path="extension/package.json" Addressable="true"/>
    <Asset Type="Microsoft.VisualStudio.Services.Icons.Default" Path="extension/icon.png" Addressable="true"/>
    <Asset Type="Microsoft.VisualStudio.Services.Content.Details" Path="extension/README.md" Addressable="true"/>
    <Asset Type="Microsoft.VisualStudio.Services.Content.Changelog" Path="extension/CHANGELOG.md" Addressable="true"/>
  </Assets>
</PackageManifest>
'@
[System.IO.File]::WriteAllText("$tempDir\extension.vsixmanifest", $vsixManifest, [System.Text.Encoding]::UTF8)

# Remove old archives
if (Test-Path $outputVsix) { Remove-Item $outputVsix -Force }
if (Test-Path $outputZip) { Remove-Item $outputZip -Force }

# Create new VSIX (which is zip)
[System.IO.Compression.ZipFile]::CreateFromDirectory($tempDir, $outputVsix)

# Create standalone zip package for user download
[System.IO.Compression.ZipFile]::CreateFromDirectory("$tempDir\extension", $outputZip)

# Cleanup
Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue

Write-Output "Successfully built clean Pinkie VSIX & ZIP packages!"
