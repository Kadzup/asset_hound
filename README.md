<div align="center">
  <img src="https://raw.githubusercontent.com/Kadzup/asset_hound/refs/heads/main/doc/logo.png" alt="Asset Hound Logo" width="200">

  <h1>Asset Hound 🐶</h1>
  <p><strong>A lightning-fast CLI tool to sniff out and remove unused assets in your Flutter projects.</strong></p>

  <p>
    <a href="https://pub.dev/packages/asset_hound"><img src="https://img.shields.io/pub/v/asset_hound.svg" alt="Pub Version"></a>
    <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License: MIT"></a>
  </p>
</div>

---

## 🧐 The Problem

As Flutter apps grow, developers often leave behind unused images, fonts, and SVGs. These "ghost assets" bloat your final APK/IPA size, hurting your app's download conversion rate. 

**Asset Hound** automatically scans your `pubspec.yaml`, searches your file system, and analyzes your Dart code to find exactly which assets are wasting space—allowing you to safely delete them and generate beautiful savings reports.

---

## 🚀 Quick Start

Asset Hound is designed to be run globally from your terminal. Activate it once:

```bash
dart pub global activate asset_hound
```

Navigate to your Flutter project and let the hound off the leash:

```bash
dart run asset_hound scan
```

---

## 🛠️ Usage & Commands

Run the `scan` command to analyze your project. You can customize the scan using various flags:

| Flag                | Abbreviation | Description                                                                  |
| :------------------ | :----------: | :--------------------------------------------------------------------------- |
| `--report=<format>` |     `-r`     | Generates a savings report. Supported formats: `html`, `json`.               |
| `--auto-fix`        |     `-f`     | **(Caution)** Automatically deletes the unused assets found during the scan. |
| `--dry-run`         |     `-d`     | Simulates an auto-fix deletion without actually harming any files.           |
| `--verbose`         |     `-v`     | Prints detailed logging information. Great for debugging.                    |
| `--protect=<list>`  |     `-p`     | Comma-separated list of native config packages to protect from deletion.     |

**Example: Generate a beautiful HTML dashboard of your unused assets:**
```bash
dart run asset_hound scan --report=html
```

---

## ⚙️ Configuration (Optional)

Asset Hound is smart enough to handle dynamically generated paths (like `assets/icons/icon_$index.png`) using fuzzy directory matching. However, if you need to explicitly ignore certain directories, you can configure it directly in your `pubspec.yaml`.

Add an `asset_hound` block to the bottom of your file:

```yaml
# pubspec.yaml

asset_hound:
  ignore:
    # Ignore all videos
    - assets/videos/**
    # Ignore a specific file
    - assets/images/do_not_delete.png
```

### Native Package Protection
By default, Asset Hound automatically protects native assets configured by popular packages (like `flutter_native_splash` and `flutter_launcher_icons`). If you use custom packages, you can protect them via the CLI:

```bash
dart run asset_hound scan --protect=my_custom_splash,other_icons
```

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/Kadzup/asset_hound/issues).