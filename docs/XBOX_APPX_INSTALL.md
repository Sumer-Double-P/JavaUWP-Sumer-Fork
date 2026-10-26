# Xbox .appx build and install guide

This project builds a signed UWP package for Xbox Series S/X. The package is produced as a `.appx` file, not as a standard Java app or APK.

## What this repo produces

From the repo root, the build script creates a signed package like:

```text
output\BanditLauncher_<appx-version>.appx
```

The repo's build docs confirm the package is generated locally with:

```powershell
.\build.ps1
```

For the native mouse build, the release also includes a matching `.cer` certificate.

## Requirements

- Windows 11
- Visual Studio 2022 with:
  - Desktop development with C++
  - Universal Windows Platform development
  - Windows 10/11 SDK
- PowerShell 5.1 or newer
- Git for Windows
- JDKs used by this project:
  - JDK 25 for the main build runtime and modern targets
  - JDK 21 for packaged Java 21 runtime and compatibility checks
  - JDK 17 for Java 17 catalog targets

The repo includes the build instructions in `docs/BUILDING.md`.

## Build locally

Run the setup once on a clean machine:

```powershell
.\scripts\setup.ps1
```

Then build the package:

```powershell
.\build.ps1
```

If you want to keep the generated staging files for inspection:

```powershell
.\build.ps1 -KeepStaging
```

The build also accepts temporary overrides, for example:

```powershell
.\build.ps1 -McVersion 1.21.11 -FabricLoader 0.19.5 -AssetIndex 29
```

## Output files

The normal output is:

```text
output\BanditLauncher_<appx-version>.appx
```

If you are using the native mouse build, also install the matching certificate from the release:

```text
BanditLauncher-native-mouse.cer
```

## Install on Xbox

1. Put your Xbox in Developer Mode.
2. Open Xbox Device Portal on the console.
3. Upload the generated `.appx` package.
4. If the package is a native mouse build, install the matching `.cer` certificate first or alongside the app installation.
5. Install the package from the Device Portal.
6. Start the app from the Xbox home screen.

## Important notes

- This is not a Java project compiled with Gradle or Maven.
- This repo builds a Windows UWP/Xbox app in C++.
- The package is intended for Xbox Series S and Series X only.
- The project includes nightly and native mouse builds, but the repository itself is the source for local builds.
- A `.appx` file alone is not enough for some builds; the certificate may also be required.

## Recommended quick path

If you want the fastest path to get a working local install on a dev Xbox:

```powershell
.\scripts\setup.ps1
.\build.ps1 -KeepStaging
```

Then upload the resulting `.appx` file through Xbox Device Portal and install it with the matching `.cer` when required.

## Related docs

- `docs/BUILDING.md`
- `README.md`
- `mesa-runtime/README.md`

