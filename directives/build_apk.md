# Directive: Build and Deploy APK

## Objective
Export the Godot project as an Android APK and install it on a connected USB device for testing.

## Prerequisites
- The Godot 4 executable must be accessible from the command line (e.g., `godot`).
- An Android device must be connected and authorized for USB debugging via ADB.
- `adb` must be available in the system PATH.

## Tools
- Godot 4 CLI (`godot --export-debug "Android"`)
- ADB (`adb install -r`)

## Procedure
1. Create a `build` directory if it doesn't exist.
2. Run Godot headless to export the debug APK to `build/LootClicker.apk`.
3. Verify ADB sees the connected device.
4. Use `adb install -r build/LootClicker.apk` to push the game to the device.
5. Launch the main Godot intent (`adb shell monkey -p com.artuq.lootclicker -c android.intent.category.LAUNCHER 1`).

## Outputs
- Built `LootClicker.apk`.
- Game launched on the physical device.