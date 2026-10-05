# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2024-01-XX

### Added
- Initial release of DeepSeek Harness Shell
- Electron wrapper for DeepSeek Harness WebUI
- Windows Start Menu integration
- Batch launcher (`启动 DeepSeek Harness.bat`)
- VBScript launcher (no console window)
- EXE launcher with embedded icon support
- Python script for generating valid Windows ICO files
- Plugin sync fix for account plugin
- Fix for `supportsImageAttachments` error
- Download handling (allows exports, blocks self-update installer)

### Fixed
- Account plugin loading error in client-modules sync
- `resolve(...).supportsImageAttachments is not a function` crash
- Windows Start Menu icon display issues

### Changed
- Removed aggressive HTML/URL stripping of account plugin from main.js
- Updated overlay-guard wrapper to forward `supportsImageAttachments`
