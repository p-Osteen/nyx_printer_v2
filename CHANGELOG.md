## 1.2.2
- Migrate Android plugin to use built-in Kotlin configuration, resolving pub.dev legacy warning.

## 1.2.1
- Update documentation and `pubspec.yaml` to reflect `nyx_printer_v2` name and T2 Plus support.
- Update example app to properly pass `width` and `height` to `printBarcode`.

## 1.2.0
- Upgrade printer service AIDL interface to the latest version supporting newer T2 Plus devices.
- Update Kotlin implementation of `printBarcode` to support updated signatures.

## 1.1.6
- Update example app with a modern, minimal, dark-themed UI optimized for low-end POS hardware.
- Add sample POS receipt layout and print action.

## 1.1.5
- Add missing public member API and library-level documentation.

## 1.1.4
- Adapt Android 11+ package visibility compatibility (added `net.nyx.printerservice` queries tag in example app).

## 1.1.3
- Bump package metadata and tidy formatting.

## 1.1.2
- Roll back old changes due to incompatibility issues.

## 1.1.1

- Added comprehensive error handling with timeouts for all operations
- Added new printer status methods: `getServiceVersion()`, `getPrinterModel()`, `getPrinterStatus()`
- Added `isServiceConnected()` to check printer service availability
- Added `paperFeed()` for precise paper positioning
- Enhanced service connection management with auto-reconnect
- Improved input validation for all print methods
- Fixed platform interface implementation (removed unnecessary UnimplementedError)

## 1.1.0

- Fixed line spacing issue in NB55
- Implemented paperOut

## 1.0.1

- Fixed type mismatch issue

## 1.0.0

- Initial release
