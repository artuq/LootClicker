# Android release setup (0.9.2)

The code and Android plugins are in the repository. This is an update of the already published app, not a new listing. Two Google Console inputs must still be supplied before promoting version 52 to production.

## 1. Google Play product

The current production build (version code 51) does not declare Google Play Billing, so Play Console initially shows **Upload a new APK** instead of **Create one-time product**. First upload the signed version-code-52 AAB to the **internal testing** track and let Play finish processing it. Do not replace the production release just to unlock the catalog screen.

Then open **Monetize with Play → Products → One-time products** and create the product with:

```text
Product ID: remove_ads_lifetime
Purchase option ID: standard
Purchase type: Buy
```

Use **Digital content**, leave multi-quantity purchasing disabled, configure availability and regional prices in the purchase option, and activate it. Do not use **Rent**, a subscription, or a consumable setup. The first Buy option is the backwards-compatible option used by the Billing integration.

It is a durable, non-consumable entitlement. The game queries Google Play at startup, after resume, and when the player selects **Restore Purchases**. It removes banners, automatic interstitials, and rewarded videos. Full Heal, offline x2 Gold, and revive remain available to owners without watching an ad.

No price or URL is hardcoded in the game. Google Play supplies the user's localized price and opens its native purchase sheet. This implementation does not require a developer-operated backend; Google Play remains the purchase source of truth. Server-side token verification can be added later for stronger fraud resistance, but it is not needed to configure or test this release. Do not create a consumable Starter Pack until its reward and repeat-purchase rules are specified.

Test purchases from an internal/closed Play track using a license tester account. Billing flows do not work in an editor build or a directly sideloaded package.

## 2. Firebase configuration

Register an Android app with package name `com.artuq.lootclicker2` in Firebase Console, download its `google-services.json`, and place it at:

```text
res://google-services.json
```

The Android release guard detects the file and applies Google Services during export. Without it, the game and AAB still build, but Firebase initialization remains disabled and reports a clear message in logs.

Analytics starts with collection and Consent Mode storage denied. Players can opt in or out in Settings.

## 3. Play Console declarations

Before promoting version code 52 from internal/closed testing to production:

- update the hosted privacy policy from `docs/privacy-policy.html`;
- review Data Safety for AdMob, optional Firebase Analytics, and purchase data handled by Google Play;
- verify the one-time product is active for the same package and track;
- keep notification purpose accurate: optional local 12 h / 24 h return reminders.

Keep package `com.artuq.lootclicker2` and the existing upload key unchanged. Start with the internal or closed track, then use a staged production rollout while monitoring Android vitals. Do not replace the current production release until the candidate has passed Play-distributed Billing and notification tests.

## 4. Export safeguards

Use Godot 4.7.1 and the Gradle Android template. `Android Release Guard` automatically:

- enables R8 and resource shrinking for release builds;
- writes conservative Godot/plugin ProGuard rules;
- removes exact-alarm and battery-optimization-exemption permissions;
- applies Google Services only when `google-services.json` is present.
