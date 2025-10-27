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
