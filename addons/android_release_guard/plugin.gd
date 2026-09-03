@tool
extends EditorPlugin

var export_plugin: AndroidReleaseExportPlugin


func _enter_tree() -> void:
	export_plugin = AndroidReleaseExportPlugin.new()
	add_export_plugin(export_plugin)


func _exit_tree() -> void:
	remove_export_plugin(export_plugin)
	export_plugin = null


class AndroidReleaseExportPlugin extends EditorExportPlugin:
	const BUILD_GRADLE_PATH := "res://android/build/build.gradle"
	const CONFIG_GRADLE_PATH := "res://android/build/config.gradle"
	const PROGUARD_RULES_PATH := "res://android/build/proguard-rules.pro"
	const BUILD_GDIGNORE_PATH := "res://android/build/.gdignore"
	const GOOGLE_SERVICES_PATH := "res://google-services.json"


	func _get_name() -> String:
		return "Android Release Guard"


	func _supports_platform(platform: EditorExportPlatform) -> bool:
		return platform is EditorExportPlatformAndroid


	func _get_android_manifest_element_contents(
		platform: EditorExportPlatform, _debug: bool
	) -> String:
		if not _supports_platform(platform):
			return ""
		# The scheduler falls back to inexact alarms. These two permissions are
		# intentionally removed because retention reminders are not exact alarms.
		return """
		<uses-permission
			android:name="android.permission.SCHEDULE_EXACT_ALARM"
			tools:node="remove" />
		<uses-permission
			android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS"
			tools:node="remove" />
		"""


	func _export_begin(
		features: PackedStringArray, _is_debug: bool, _path: String, _flags: int
	) -> void:
		if not features.has("android"):
			return
		_ensure_android_build_is_ignored()
		_patch_gradle_build()
		_patch_androidx_activity_version()
		_write_proguard_rules()


	func _ensure_android_build_is_ignored() -> void:
		# Exported project assets live below android/build. Without this marker the
		# editor imports its own generated output on the next run and Android's
		# resource merger later sees invalid *.webp.import files.
		if FileAccess.file_exists(BUILD_GDIGNORE_PATH):
			return
		var file := FileAccess.open(BUILD_GDIGNORE_PATH, FileAccess.WRITE)
		if file == null:
			push_error("[Android Release Guard] Could not create android/build/.gdignore.")
			return
		file.store_string("# Generated Android template; never scan as Godot project data.\n")
		file.close()


	func _patch_gradle_build() -> void:
		if not FileAccess.file_exists(BUILD_GRADLE_PATH):
			push_error(
				"[Android Release Guard] Custom Android build template is missing. "
				+ "Run Project > Install Android Build Template and export again."
			)
			return

		var content := FileAccess.get_file_as_string(BUILD_GRADLE_PATH)
		var changed := false
		if not "androidx.activity:activity:$versions.activityVersion" in content:
			var fragment_dependency := (
				"    implementation \"androidx.fragment:fragment:$versions.fragmentVersion\""
			)
			if not fragment_dependency in content:
				push_error("[Android Release Guard] Could not find the Fragment dependency.")
				return
			content = content.replace(
				fragment_dependency,
				"    implementation \"androidx.activity:activity:$versions.activityVersion\"\n"
				+ fragment_dependency
			)
			changed = true
		if not "minifyEnabled true" in content:
			var build_types_position := content.find("    buildTypes {")
			var release_position := content.find("        release {", build_types_position)
			if build_types_position < 0 or release_position < 0:
				push_error("[Android Release Guard] Could not find the release build type.")
				return
			var insertion_position := content.find("\n", release_position) + 1
			var r8_settings := (
				"            minifyEnabled true\n"
				+ "            shrinkResources true\n"
				+ "            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'\n"
			)
			content = content.substr(0, insertion_position) + r8_settings + content.substr(insertion_position)
			changed = true

		if FileAccess.file_exists(GOOGLE_SERVICES_PATH) and not "com.google.gms.google-services" in content:
			var buildscript := """buildscript {
		repositories {
			google()
			mavenCentral()
		}
		dependencies {
			classpath 'com.google.gms:google-services:4.4.4'
		}
	}

"""
			content = buildscript + content + "\napply plugin: 'com.google.gms.google-services'\n"
			changed = true

		if not changed:
			return
		var file := FileAccess.open(BUILD_GRADLE_PATH, FileAccess.WRITE)
		if file == null:
			push_error("[Android Release Guard] Could not write build.gradle.")
			return
		file.store_string(content)
		file.close()
		print("[Android Release Guard] Applied reproducible Android release settings.")


	func _patch_androidx_activity_version() -> void:
		if not FileAccess.file_exists(CONFIG_GRADLE_PATH):
			push_error("[Android Release Guard] Android config.gradle is missing.")
			return
		var content := FileAccess.get_file_as_string(CONFIG_GRADLE_PATH)
		if "activityVersion" in content:
			return
		var kotlin_version := "    kotlinVersion      : '2.1.21',"
		if not kotlin_version in content:
			push_error("[Android Release Guard] Could not find the Kotlin version anchor.")
			return
		content = content.replace(
			kotlin_version,
			kotlin_version + "\n    activityVersion    : '1.10.1',"
		)
		var file := FileAccess.open(CONFIG_GRADLE_PATH, FileAccess.WRITE)
		if file == null:
			push_error("[Android Release Guard] Could not write config.gradle.")
			return
		file.store_string(content)
		file.close()


	func _write_proguard_rules() -> void:
		var rules := """# Keep Godot's JNI surface and Android plugin entry points.
-keepclasseswithmembers,includedescriptorclasses class * {
    native <methods>;
}
-keep class org.godotengine.godot.** { *; }
-keep class org.godotengine.plugin.** { *; }
-keep class com.poingstudios.godot.admob.** { *; }
-keep class com.godotx.firebase.** { *; }

# The Poing AdMob AAR currently has no consumer ProGuard rules, so its Godot
# bridge must be kept explicitly. Keep enum members used by bridges which are
# converted to Godot dictionaries as well.
-keepclassmembers enum * { public static **[] values(); public static ** valueOf(java.lang.String); }
"""
		var file := FileAccess.open(PROGUARD_RULES_PATH, FileAccess.WRITE)
		if file == null:
			push_error("[Android Release Guard] Could not write proguard-rules.pro.")
			return
		file.store_string(rules)
		file.close()
