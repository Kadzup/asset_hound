## 1.0.1

* **New Feature:** Added the `--yes` (`-y`) flag to bypass the deletion confirmation prompt. Perfect for automated CI/CD pipelines!
* **Enhancement:** Extracted deletion logic into a dedicated `AssetCleaner` class for cleaner architecture and reusability.
* **Docs:** Updated the README with the official Asset Hound logo and documented the `--yes` and `--scope` flags.

## 1.0.0

* Initial release of Asset Hound! 🐶
* Added `scan` command with `--auto-fix` and `--dry-run` flags.
* Added HTML and JSON report generation via `--report` flag.
* Added smart Code Scanner with fuzzy directory matching.
* Added automatic protection for native configuration packages.