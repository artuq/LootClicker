# Test suites

These lightweight tests mirror the regression-test style used in the Water Sort project and require no third-party test framework.

```bash
/path/to/Godot --headless --path . --script res://tests/test_platform_features.gd
/path/to/Godot --headless --path . --script res://tests/test_ui_layout.gd
```

Visible production smoke test (opens a real window and closes automatically):

```bash
/path/to/Godot --path . --script res://tests/test_visual_smoke.gd
```

Coverage:

- Google Play Remove Ads purchase/pending/restore contracts;
- all-ad gating while rewarded gameplay bonuses remain available without video;
- Firebase consent and gameplay event names/parameters;
- 12 h / 24 h local notification definitions and deep link;
- Godot/renderer/orientation/R8/plugin release configuration;
- Settings, Store, and title layouts at phone, tablet, and landscape sizes;
- real new-game startup without a tutorial, immediate auto-attack, tap combat, and live portrait-to-landscape resize.

Native purchase confirmation requires a Play internal/closed-track build and a license tester account. The Android release export and merged-manifest inspection cover native packaging locally.
