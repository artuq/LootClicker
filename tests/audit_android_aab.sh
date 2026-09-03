#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
	echo "Usage: $0 path/to/release.aab" >&2
	exit 2
fi

aab_path="$1"
if [[ ! -f "$aab_path" ]]; then
	echo "AAB not found: $aab_path" >&2
	exit 2
fi

android_tools_root="${ANDROID_TOOLS_ROOT:-/Users/magda/android-tools}"
java_home="${JAVA_HOME:-$android_tools_root/jdk-17.0.11+9/Contents/Home}"
java_bin="$java_home/bin/java"
bundletool_jar="${BUNDLETOOL_JAR:-$android_tools_root/bundletool.jar}"
apkanalyzer_bin="${APKANALYZER:-$android_tools_root/android-sdk/cmdline-tools/latest/bin/apkanalyzer}"

for required in "$java_bin" "$bundletool_jar" "$apkanalyzer_bin"; do
	if [[ ! -e "$required" ]]; then
		echo "Required Android audit tool not found: $required" >&2
		exit 2
	fi
done

audit_dir="$(mktemp -d "${TMPDIR:-/tmp}/lootclicker-aab-audit.XXXXXX")"
trap 'rm -rf "$audit_dir"' EXIT
apks_path="$audit_dir/release.apks"
apk_path="$audit_dir/universal.apk"

"$java_bin" -jar "$bundletool_jar" validate --bundle="$aab_path" >/dev/null
"$java_bin" -jar "$bundletool_jar" build-apks \
	--bundle="$aab_path" \
	--output="$apks_path" \
	--mode=universal \
	--overwrite >/dev/null
unzip -p "$apks_path" universal.apk > "$apk_path"

packages="$(
	JAVA_HOME="$java_home" "$apkanalyzer_bin" dex packages "$apk_path"
)"

bridge_classes=(
	com.poingstudios.godot.admob.ads.PoingGodotAdMob
	com.poingstudios.godot.admob.ads.PoingGodotAdMobAdView
	com.poingstudios.godot.admob.ads.PoingGodotAdMobAdSize
	com.poingstudios.godot.admob.ads.PoingGodotAdMobInterstitialAd
	com.poingstudios.godot.admob.ads.PoingGodotAdMobRewardedAd
	com.poingstudios.godot.admob.ads.PoingGodotAdMobRewardedInterstitialAd
	com.poingstudios.godot.admob.ads.PoingGodotAdMobConsentInformation
	com.poingstudios.godot.admob.ads.PoingGodotAdMobUserMessagingPlatform
)

for bridge_class in "${bridge_classes[@]}"; do
	if ! grep -Fq "$bridge_class" <<<"$packages"; then
		echo "FAIL: R8 removed required AdMob bridge class: $bridge_class" >&2
		exit 1
	fi
done

version_code="$(JAVA_HOME="$java_home" "$apkanalyzer_bin" manifest version-code "$apk_path")"
version_name="$(JAVA_HOME="$java_home" "$apkanalyzer_bin" manifest version-name "$apk_path")"
if [[ "$version_code" != "53" || "$version_name" != "0.9.3" ]]; then
	echo "FAIL: expected v53 / 0.9.3, got v$version_code / $version_name" >&2
	exit 1
fi

echo "PASS: v$version_code / $version_name contains all ${#bridge_classes[@]} AdMob bridge classes after R8."
